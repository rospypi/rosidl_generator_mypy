add_custom_command(
  OUTPUT ${_generated_pyi_files}
  COMMAND ${PYTHON_EXECUTABLE} ${rosidl_generator_mypy_BIN}
  --generator-arguments-file "${generator_arguments_file}"
  DEPENDS ${target_dependencies} ${rosidl_generate_interfaces_TARGET}
  COMMENT "Generating Python stub for ROS interfaces"
  VERBATIM
)

if(TARGET ${rosidl_generate_interfaces_TARGET}${_target_suffix})
  message(WARNING "Custom target ${rosidl_generate_interfaces_TARGET}${_target_suffix} already exists")
else()
  add_custom_target(
    ${rosidl_generate_interfaces_TARGET}${_target_suffix} ALL
    DEPENDS
    ${_generated_pyi_files}
  )
endif()
