cmake_minimum_required(VERSION 3.5)

project(rosidl_generator_mypy)

find_package(ament_cmake REQUIRED)
find_package(ament_cmake_python REQUIRED)
find_package(rosidl_cmake REQUIRED)
find_package(rosidl_generator_py REQUIRED)

ament_export_dependencies(ament_cmake)
ament_export_dependencies(rmw)
ament_export_dependencies(rosidl_cmake)
ament_export_dependencies(rosidl_generator_py)

ament_index_register_resource("rosidl_generator_packages")

ament_python_install_package(${PROJECT_NAME})

ament_package(
  CONFIG_EXTRAS "cmake/register_mypy.cmake"
    "rosidl_generator_mypy-extras.cmake.in"
)

install(
  PROGRAMS bin/rosidl_generator_mypy
  DESTINATION lib/rosidl_generator_mypy
)
install(
  DIRECTORY cmake resource
  DESTINATION share/${PROJECT_NAME}
)
