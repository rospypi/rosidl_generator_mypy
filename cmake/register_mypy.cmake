macro(rosidl_generator_mypy_extras BIN GENERATOR_FILES TEMPLATE_DIR)
  find_package(ament_cmake_core QUIET REQUIRED)
  # This idl generator must run after rosidl_generator_py runs
  find_package(rosidl_generator_py QUIET REQUIRED)

  ament_register_extension(
    "rosidl_generate_idl_interfaces"
    "rosidl_generator_mypy"
    "rosidl_generator_mypy_generate_interfaces.cmake")

  normalize_path(BIN "${BIN}")
  set(rosidl_generator_mypy_BIN "${BIN}")

  set(rosidl_generator_mypy_GENERATOR_FILES "")
  foreach(_generator_file ${GENERATOR_FILES})
    normalize_path(_generator_file "${_generator_file}")
    list(APPEND rosidl_generator_mypy_GENERATOR_FILES "${_generator_file}")
  endforeach()

  normalize_path(TEMPLATE_DIR "${TEMPLATE_DIR}")
  set(rosidl_generator_mypy_TEMPLATE_DIR "${TEMPLATE_DIR}")
endmacro()
