@# Included from rosidl_generator_mypy/resource/_idl.pyi.em
@#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@{
import builtins
import inspect

from rosidl_parser.definition import EMPTY_STRUCTURE_REQUIRED_MEMBER_NAME

from rosidl_generator_mypy import to_type_annotation

builtin_items = set(dict(inspect.getmembers(builtins)).keys())
current_namespace = message.structure.namespaced_type
members = []
for member in message.structure.members:
    if len(message.structure.members) == 1 and member.name == EMPTY_STRUCTURE_REQUIRED_MEMBER_NAME:
        continue

    noqa_string = ''
    if member.name in builtin_items:
        noqa_string = '  # noqa: A003'

    members.append(
        (member.name, to_type_annotation(current_namespace, defined_classes, member.type), noqa_string)
    )
}@
@#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@{
if generate_imports:
    from rosidl_generator_mypy import append_import_statements_msg

    # NOTE: No import statement is required for constants as we cannot use any NamespacedType
    TEMPLATE(
        '_imports.pyi.em',
        component=message, defined_classes=defined_classes, generator=append_import_statements_msg)
}@
@#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

class Metaclass_@(message.structure.namespaced_type.name)(type):
    _CREATE_ROS_MESSAGE: typing.Any = ...
    _CONVERT_FROM_PY: typing.Any = ...
    _CONVERT_TO_PY: typing.Any = ...
    _DESTROY_ROS_MESSAGE: typing.Any = ...
    _TYPE_SUPPORT: typing.Any = ...
    __constants: typing.Dict[str, typing.Any] = ...

    @@classmethod
    def __import_type_support__(cls) -> None: ...
    @@classmethod
    def __prepare__(
        cls, __name: str, __bases: typing.Tuple[type, ...], **kwargs: typing.Any
    ) -> typing.Mapping[str, typing.Any]: ...
@[for constant in message.constants]@
    @@property
    def @(constant.name)(self) -> @(to_type_annotation(current_namespace, defined_classes, constant.type).getter): ...
@[end for]@
@[for member in message.structure.members]@
@[  if member.has_annotation('default')]@
    @@property
    def @(member.name.upper())__DEFAULT(cls) -> @(to_type_annotation(current_namespace, defined_classes, member.type).getter): ...
@[  end if]@
@[end for]@

class @(message.structure.namespaced_type.name)(metaclass=Metaclass_@(message.structure.namespaced_type.name)):
    __slots__: typing.List[str] = ...
    _fields_and_field_types: typing.Dict[str, str] = ...
    SLOT_TYPES: typing.Tuple[rosidl_parser.definition.AbstractType, ...]  = ...

    def __init__(
        self,
@[if len(members)]@
        *,
@[end if]@
@[for name, annotation, noqa_string in members]@
        @(name): @(annotation.getter) = ...,@(noqa_string)
@[end for]@
        **kwargs: typing.Any,
    ) -> None: ...
    def __repr__(self) -> str: ...
    def __eq__(self, other: typing.Any) -> bool: ...
    @@classmethod
    def get_fields_and_field_types(cls) -> typing.Dict[str, str]: ...
    # Members
@[for name, annotation, noqa_string in members]@
    @@property@(noqa_string)
    def @(name)(self) -> @(annotation.getter): ...@(noqa_string)
    @@@(name).setter@(noqa_string)
    def @(name)(self, value: @(annotation.setter)) -> None: ...@(noqa_string)
@[end for]@
