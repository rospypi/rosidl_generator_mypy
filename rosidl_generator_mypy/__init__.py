import os
import pathlib
from typing import Dict, List, NamedTuple, Optional, Set, Tuple

from rosidl_generator_py import generate_py_impl
from rosidl_parser.definition import (
    AbstractNestedType,
    AbstractSequence,
    AbstractType,
    Action,
    Array,
    IdlContent,
    IdlLocator,
    Message,
    NamespacedType,
    Service,
)
from rosidl_parser.parser import parse_idl_file
from rosidl_pycommon import (
    convert_camel_case_to_lower_case_underscore,
    generate_files,
    read_generator_arguments,
)

SPECIAL_NESTED_BASIC_TYPES = ["int", "float"]


class Annotation(NamedTuple):
    getter: str
    setter: str


def generate(generator_arguments_file: str) -> List[str]:
    mapping = {
        "_idl.pyi.em": "_%s.pyi",
    }
    generated_files: List[str] = generate_files(generator_arguments_file, mapping)

    args = read_generator_arguments(generator_arguments_file)
    package_name = args["package_name"]

    # For __init__.pyi, it is required to output the exact same contents as
    # rosidl_python does.
    modules: Dict[str, Set[str]] = {}
    idl_content = IdlContent()
    for idl_tuple in args.get("idl_tuples", []):
        idl_parts = idl_tuple.rsplit(":", 1)
        assert len(idl_parts) == 2

        idl_rel_path = pathlib.Path(idl_parts[1])
        idl_stems = modules.setdefault(str(idl_rel_path.parent), set())
        idl_stems.add(idl_rel_path.stem)

        locator = IdlLocator(*idl_parts)
        idl_file = parse_idl_file(locator)
        idl_content.elements += idl_file.content.elements

    for subfolder in modules.keys():
        with open(
            os.path.join(args["output_dir"], subfolder, "__init__.pyi"), "w"
        ) as f:
            for idl_stem in sorted(modules[subfolder]):
                module_name = "_{}".format(
                    convert_camel_case_to_lower_case_underscore(idl_stem)
                )
                f.write(
                    f"from {package_name}.{subfolder}.{module_name} import "
                    f"{idl_stem} as {idl_stem}  # noqa: F401\n"
                )

    return generated_files


def get_defined_classes_msg(msg: Message) -> Set[str]:
    return {msg.structure.namespaced_type.name}


def get_defined_classes_srv(srv: Service) -> Set[str]:
    ret: Set[str] = {srv.namespaced_type.name}
    ret.update(get_defined_classes_msg(srv.request_message))
    ret.update(get_defined_classes_msg(srv.response_message))
    return ret


def get_defined_classes_action(action: Action) -> Set[str]:
    ret: Set[str] = {action.namespaced_type.name}
    ret.update(get_defined_classes_msg(action.goal))
    ret.update(get_defined_classes_msg(action.result))
    ret.update(get_defined_classes_msg(action.feedback))
    ret.update(get_defined_classes_srv(action.send_goal_service))
    ret.update(get_defined_classes_srv(action.get_result_service))
    ret.update(get_defined_classes_msg(action.feedback_message))

    return ret


def get_defined_classes(content: IdlContent) -> Set[str]:
    ret: Set[str] = set()
    for item in content.elements:
        if isinstance(item, Message):
            ret.update(get_defined_classes_msg(item))
        elif isinstance(item, Service):
            ret.update(get_defined_classes_srv(item))
        elif isinstance(item, Action):
            ret.update(get_defined_classes_action(item))

    return ret


def to_type_annotation(
    current_namespace: NamespacedType, defined_classes: Set[str], type_: AbstractType
) -> Annotation:
    if isinstance(type_, NamespacedType):
        if type_.namespaces == current_namespace.namespaces:
            if type_.name in defined_classes:
                # member is defined in the same module, so no need to add namespaces
                annotation = '"{}"'.format(type_.name)
                return Annotation(annotation, annotation)

            # NOTE: We export .pyi files, which don't affect the Python code execution at all.
            # As mypy solves the import cycles properly,
            # we import classes from not a module but a package.
            # (i.e. in the same way as imports for other packages)

        annotation = "{}.{}".format(".".join(type_.namespaces), type_.name)
        return Annotation(annotation, annotation)

    try:
        ret = generate_py_impl.get_python_type(type_)
        if ret is not None:
            return Annotation(str(ret), str(ret))
    except Exception:
        pass

    if isinstance(type_, Array):
        # The type_ will be Array for bounded lists
        type_annotation = to_type_annotation(
            current_namespace, defined_classes, type_.value_type
        )
        if type_annotation.getter in SPECIAL_NESTED_BASIC_TYPES:
            # eg: int64[4]
            return Annotation(
                "np.ndarray",
                "typing.Union[typing.Sequence[{}], np.ndarray]".format(
                    type_annotation.setter
                ),
            )

        # eg: std_msgs/Header[4]
        return Annotation(
            "typing.Sequence[{}]".format(type_annotation.getter),
            "typing.Sequence[{}]".format(type_annotation.setter),
        )
    if isinstance(type_, AbstractSequence):
        # The type_ will be AbstractSequence for unbounded lists
        type_annotation = to_type_annotation(
            current_namespace, defined_classes, type_.value_type
        )
        if type_annotation.getter in SPECIAL_NESTED_BASIC_TYPES:
            # eg: int64[]
            return Annotation(
                "array.array[{}]".format(type_annotation.getter),
                "typing.Sequence[{}]".format(type_annotation.setter),
            )

        # eg: std_msgs/Header[]
        return Annotation(
            "typing.Sequence[{}]".format(type_annotation.getter),
            "typing.Sequence[{}]".format(type_annotation.setter),
        )

    return Annotation(str(type_), str(type_))


def _get_import_statement(
    current_namespace: NamespacedType, defined_classes: Set[str], type_: AbstractType
) -> Tuple[Optional[str], bool]:
    if isinstance(type_, NamespacedType):
        is_firstparty = False
        if type_.namespaces == current_namespace.namespaces:
            is_firstparty = True

            if type_.name in defined_classes:
                # member is defined in the same module, so no need to add imports
                return None, is_firstparty

        return "import {}".format(".".join(type_.namespaces)), is_firstparty

    if isinstance(type_, AbstractNestedType):
        return _get_import_statement(
            current_namespace, defined_classes, type_.value_type
        )

    return None, False


def append_import_statements_msg(
    msg: Message,
    defined_classes: Set[str],
    third_parties: Set[str],
    first_parties: Set[str],
) -> None:
    third_parties.add("import rosidl_parser.definition")
    if msg.structure is None or msg.structure.members is None:
        return None

    for member in msg.structure.members:
        ret, is_first_party = _get_import_statement(
            msg.structure.namespaced_type, defined_classes, member.type
        )
        if ret is not None:
            if is_first_party:
                first_parties.add(ret)
            else:
                third_parties.add(ret)


def append_import_statements_srv(
    srv: Service,
    defined_classes: Set[str],
    third_parties: Set[str],
    first_parties: Set[str],
) -> None:
    append_import_statements_msg(
        srv.request_message, defined_classes, third_parties, first_parties
    )
    append_import_statements_msg(
        srv.response_message, defined_classes, third_parties, first_parties
    )


def append_import_statements_action(
    action: Action,
    defined_classes: Set[str],
    third_parties: Set[str],
    first_parties: Set[str],
) -> None:
    append_import_statements_msg(
        action.goal, defined_classes, third_parties, first_parties
    )
    append_import_statements_msg(
        action.result, defined_classes, third_parties, first_parties
    )
    append_import_statements_msg(
        action.feedback, defined_classes, third_parties, first_parties
    )
    append_import_statements_srv(
        action.send_goal_service, defined_classes, third_parties, first_parties
    )
    append_import_statements_srv(
        action.get_result_service, defined_classes, third_parties, first_parties
    )
    append_import_statements_msg(
        action.feedback_message, defined_classes, third_parties, first_parties
    )
