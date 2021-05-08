# generated from rosidl_generator_mypy/resource/_idl.pyi.em
# with input from @(package_name):@(interface_path)
# generated code does not contain a copyright notice

@
@#######################################################################
@# EmPy template for generating _<idl>.pyi files
@#
@# Context:
@#  - package_name (string)
@#  - interface_path (Path relative to the directory named after the package)
@#  - content (IdlContent, list of elements, e.g. Messages or Services)
@#######################################################################
@{
from rosidl_generator_mypy import get_defined_classes

defined_classes = get_defined_classes(content)
}@
@#######################################################################
@# Handle messages
@#######################################################################
@{
from rosidl_parser.definition import Message
}@
@[for message in content.get_elements_of_type(Message)]@
@{
TEMPLATE(
    '_msg.pyi.em',
    package_name=package_name, interface_path=interface_path, message=message,
    generate_imports=True, defined_classes=defined_classes)
}@
@[end for]@
@
@#######################################################################
@# Handle services
@#######################################################################
@{
from rosidl_parser.definition import Service
}@
@[for service in content.get_elements_of_type(Service)]@
@{
TEMPLATE(
    '_srv.pyi.em',
    package_name=package_name, interface_path=interface_path, service=service,
    generate_imports=True, defined_classes=defined_classes)
}@
@[end for]@
@
@#######################################################################
@# Handle actions
@#######################################################################
@{
from rosidl_parser.definition import Action
}@
@[for action in content.get_elements_of_type(Action)]@
@{
TEMPLATE(
    '_action.pyi.em',
    package_name=package_name, interface_path=interface_path, action=action,
    generate_imports=True, defined_classes=defined_classes)
}@
@[end for]@
