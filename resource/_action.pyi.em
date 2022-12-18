@# Included from rosidl_generator_mypy/resource/_idl.py.em
@{
if generate_imports:
    from rosidl_generator_mypy import append_import_statements_action

    TEMPLATE(
        '_imports.pyi.em',
        component=action, defined_classes=defined_classes, generator=append_import_statements_action)
}@
@#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@{
from rosidl_cmake import convert_camel_case_to_lower_case_underscore

action_name = '_' + convert_camel_case_to_lower_case_underscore(action.namespaced_type.name)
module_name = '_' + convert_camel_case_to_lower_case_underscore(interface_path.stem)

TEMPLATE(
    '_msg.pyi.em',
    package_name=package_name, interface_path=interface_path,
    message=action.goal, generate_imports=False, defined_classes=defined_classes)
TEMPLATE(
    '_msg.pyi.em',
    package_name=package_name, interface_path=interface_path,
    message=action.result, generate_imports=False, defined_classes=defined_classes)
TEMPLATE(
    '_msg.pyi.em',
    package_name=package_name, interface_path=interface_path,
    message=action.feedback, generate_imports=False, defined_classes=defined_classes)
TEMPLATE(
    '_srv.pyi.em',
    package_name=package_name, interface_path=interface_path,
    service=action.send_goal_service, generate_imports=False, defined_classes=defined_classes)
TEMPLATE(
    '_srv.pyi.em',
    package_name=package_name, interface_path=interface_path,
    service=action.get_result_service, generate_imports=False, defined_classes=defined_classes)
TEMPLATE(
    '_msg.pyi.em',
    package_name=package_name, interface_path=interface_path,
    message=action.feedback_message, generate_imports=False, defined_classes=defined_classes)
}@

class Metaclass_@(action.namespaced_type.name)(type):
    _TYPE_SUPPORT: typing.Any = ...
    @@classmethod
    def __import_type_support__(cls) -> None: ...

@#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@{

def assert_namespace_equals(action, structure):
    assert structure.namespaced_type.namespaces == action.namespaced_type.namespaces

# Make sure that all requires messages in a single file
assert_namespace_equals(action, action.goal.structure)
assert_namespace_equals(action, action.result.structure)
assert_namespace_equals(action, action.feedback.structure)

# The namespace of the following messages must be same as the action as they are defined in rosidl_parser.definition
# But we call assertions just to make sure the specification has not been changed
assert_namespace_equals(action, action.send_goal_service)
assert_namespace_equals(action, action.get_result_service)
assert_namespace_equals(action, action.feedback_message.structure)
# Then, emit member names without namespaces as follows

}@
@#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
class @(action.namespaced_type.name)(metaclass=Metaclass_@(action.namespaced_type.name)):
    Goal: TypeAlias = @(action.goal.structure.namespaced_type.name)
    Result: TypeAlias = @(action.result.structure.namespaced_type.name)
    Feedback: TypeAlias = @(action.feedback.structure.namespaced_type.name)

    class Impl:
        SendGoalService: TypeAlias = @(action.send_goal_service.namespaced_type.name)
        GetResultService: TypeAlias = @(action.get_result_service.namespaced_type.name)
        FeedbackMessage: TypeAlias = @(action.feedback_message.structure.namespaced_type.name)

        from action_msgs.srv._cancel_goal import CancelGoal as CancelGoalService
        from action_msgs.msg._goal_status_array import GoalStatusArray as GoalStatusMessage

    def __init__(self) -> None: ...
