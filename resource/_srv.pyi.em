@# Included from rosidl_generator_mypy/resource/_idl.py.em
@{
if generate_imports:
    from rosidl_generator_mypy import append_import_statements_srv

    TEMPLATE(
        '_imports.pyi.em',
        component=service, defined_classes=defined_classes, generator=append_import_statements_srv)
}@
@#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@{
from rosidl_cmake import convert_camel_case_to_lower_case_underscore

service_name = '_' + convert_camel_case_to_lower_case_underscore(service.namespaced_type.name)
module_name = '_' + convert_camel_case_to_lower_case_underscore(interface_path.stem)

TEMPLATE(
    '_msg.pyi.em',
    package_name=package_name, interface_path=interface_path,
    message=service.request_message, generate_imports=False,
    defined_classes=defined_classes)
TEMPLATE(
    '_msg.pyi.em',
    package_name=package_name, interface_path=interface_path,
    message=service.response_message, generate_imports=False,
    defined_classes=defined_classes)
}@

class Metaclass_@(service.namespaced_type.name)(type):
    _TYPE_SUPPORT: typing.Any = ...

    @@classmethod
    def __import_type_support__(cls) -> None: ...

@#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@{
# Make sure that all requires messages in a single file
assert service.request_message.structure.namespaced_type.namespaces == service.namespaced_type.namespaces
assert service.response_message.structure.namespaced_type.namespaces == service.namespaced_type.namespaces
# Then, emit member names without namespace for Request and Response as follows
}@
@#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
class @(service.namespaced_type.name)(metaclass=Metaclass_@(service.namespaced_type.name)):
    Request: TypeAlias[@(service.request_message.structure.namespaced_type.name)] = @(service.request_message.structure.namespaced_type.name)
    Response: TypeAlias[@(service.response_message.structure.namespaced_type.name)] = @(service.response_message.structure.namespaced_type.name)

    def __init__(self) -> None: ...
