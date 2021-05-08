find_package(rmw REQUIRED)

find_package(PythonInterp 3.6 REQUIRED)

set(_output_path
  "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_mypy/${PROJECT_NAME}")
set(_generated_pyi_files "")

# list the file names of generated pyi
foreach(_abs_idl_file ${rosidl_generate_interfaces_ABS_IDL_FILES})
  get_filename_component(_parent_folder "${_abs_idl_file}" DIRECTORY)
  get_filename_component(_parent_folder "${_parent_folder}" NAME)
  get_filename_component(_idl_name "${_abs_idl_file}" NAME_WE)
  string_camel_case_to_lower_case_underscore("${_idl_name}" _module_name)
  list(APPEND _generated_pyi_files
    "${_output_path}/${_parent_folder}/_${_module_name}.pyi")
endforeach()

# create pyi and py.typed to mark package PEP561 compatible
file(MAKE_DIRECTORY "${_output_path}")
file(WRITE "${_output_path}/__init__.pyi" "")
file(WRITE "${_output_path}/py.typed" "")

# NOTE: create a list of directories that have one or more pyi files
# Also add `__init__.pyi` of each package directory to `_generated_pyi_files`
# See: https://github.com/ros2/rosidl_python/blob/5b9fe9cad6876e877cbbcf17950c47a9e753c6e6/rosidl_generator_py/cmake/rosidl_generator_py_generate_interfaces.cmake#L57-L72
set(_generated_pyi_dirs "")
foreach(_generated_pyi_file ${_generated_pyi_files})
  get_filename_component(_parent_folder "${_generated_pyi_file}" DIRECTORY)
  set(_init_module "${_parent_folder}/__init__.pyi")
  list(FIND _generated_pyi_files "${_init_module}" _index)
  if(_index EQUAL -1)
    list(APPEND _generated_pyi_files "${_init_module}")

    string(LENGTH "${_output_path}" _length)
    math(EXPR _index "${_length} + 1")
    string(SUBSTRING "${_parent_folder}" ${_index} -1 _relative_directory)
    list(APPEND _generated_pyi_dirs "${_relative_directory}")
  endif()
endforeach()

# get a list of dependency files of idl files to set target_dependencies properly
set(_dependency_files "")
set(_dependencies "")
foreach(_pkg_name ${rosidl_generate_interfaces_DEPENDENCY_PACKAGE_NAMES})
  foreach(_idl_file ${${_pkg_name}_IDL_FILES})
    set(_abs_idl_file "${${_pkg_name}_DIR}/../${_idl_file}")
    normalize_path(_abs_idl_file "${_abs_idl_file}")
    list(APPEND _dependency_files "${_abs_idl_file}")
    list(APPEND _dependencies "${_pkg_name}:${_abs_idl_file}")
  endforeach()
endforeach()

set(target_dependencies
  "${rosidl_generator_mypy_BIN}"
  ${rosidl_generator_mypy_GENERATOR_FILES}
  "${rosidl_generator_mypy_TEMPLATE_DIR}/_action.pyi.em"
  "${rosidl_generator_mypy_TEMPLATE_DIR}/_idl.pyi.em"
  "${rosidl_generator_mypy_TEMPLATE_DIR}/_imports.pyi.em"
  "${rosidl_generator_mypy_TEMPLATE_DIR}/_msg.pyi.em"
  "${rosidl_generator_mypy_TEMPLATE_DIR}/_srv.pyi.em"
  ${rosidl_generate_interfaces_ABS_IDL_FILES}
  ${_dependency_files})
foreach(dep ${target_dependencies})
  if(NOT EXISTS "${dep}")
    message(FATAL_ERROR "Target dependency '${dep}' does not exist")
  endif()
endforeach()

# write build arguments into a json, then pass the file to our script
set(generator_arguments_file "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_mypy__arguments.json")
rosidl_write_generator_arguments(
  "${generator_arguments_file}"
  PACKAGE_NAME "${PROJECT_NAME}"
  IDL_TUPLES "${rosidl_generate_interfaces_IDL_TUPLES}"
  ROS_INTERFACE_DEPENDENCIES "${_dependencies}"
  OUTPUT_DIR "${_output_path}"
  TEMPLATE_DIR "${rosidl_generator_mypy_TEMPLATE_DIR}"
  TARGET_DEPENDENCIES ${target_dependencies}
)

if(NOT rosidl_generate_interfaces_SKIP_INSTALL)
  # NOTE: This generator depends on rosidl_generator_py for creating module directory.
  # As `ament_python_install_module` is not supposed to be called multiple times,
  # we have encountered the same problem as:
  # https://github.com/ros2/rosidl/issues/88 and https://github.com/ros2/rosidl/pull/89
  install(DIRECTORY "${_output_path}/__init__.pyi"
    DESTINATION "${PYTHON_INSTALL_DIR}/${PROJECT_NAME}/${_generated_py_dir}"
  )
  install(DIRECTORY "${_output_path}/py.typed"
    DESTINATION "${PYTHON_INSTALL_DIR}/${PROJECT_NAME}/${_generated_py_dir}"
  )

  foreach(_generated_py_dir ${_generated_pyi_dirs})
    install(DIRECTORY "${_output_path}/${_generated_py_dir}/"
      DESTINATION "${PYTHON_INSTALL_DIR}/${PROJECT_NAME}/${_generated_py_dir}"
      PATTERN "*.pyi"
    )
  endforeach()
endif()

set(_target_suffix "__mypy")

# NOTE: See https://github.com/ros2/rosidl/issues/124 and https://github.com/ros2/rosidl/pull/135 for the
# rationale behind the following logic. Use the same logic as the one in rosidl_python:
# https://github.com/ros2/rosidl_python/blob/5b9fe9cad6876e877cbbcf17950c47a9e753c6e6/rosidl_generator_py/cmake/rosidl_generator_py_generate_interfaces.cmake#L146-L155
set(_subdir "${CMAKE_CURRENT_BINARY_DIR}/${rosidl_generate_interfaces_TARGET}${_target_suffix}")
file(MAKE_DIRECTORY "${_subdir}")
file(READ "${rosidl_generator_mypy_DIR}/custom_command.cmake" _custom_command)
file(WRITE "${_subdir}/CMakeLists.txt" "${_custom_command}")
add_subdirectory("${_subdir}" ${rosidl_generate_interfaces_TARGET}${_target_suffix})
set_property(
  SOURCE
  ${_generated_pyi_files}
  PROPERTY GENERATED 1)

# list(APPEND ALL_OUTPUT_FILES_mypy ${GEN_OUTPUT_FILE})
