=====================
rosidl_generator_mypy
=====================

Stub files generator for the ROS2 interfaces in Python

Installation
============

.. code:: sh

    cd your_workspace/src
    git clone git@github.com:rospypi/rosidl_generator_mypy.git


Usage
=====

Add ``rosidl_generator_mypy`` to your ``CMakeLists.txt``.
This package will be registered as a ``rosidl_generate_idl_interfaces`` extension
so that ``rosidl`` automatically find and call this library when ``rosidl_generate_interfaces`` is called.

Also, keep in mind that your package should have the build dependency
for ``rosidl_generator_mypy`` in ``package.xml`` to make sure that the build tool finishes the
build of ``rosidl_generator_mypy`` before building your package.

Examples:

- CMakeLists.txt
    .. code:: cmake

        find_package(rosidl_generator_mypy REQUIRED)
- package.xml
    .. code:: xml

        <build_depend>rosidl_generator_mypy</build_depend>

rosidl CLI
----------

We are planning to provide a rosidl CLI plugin so that you can generate stub files by the unified CLI ``rosidl generate``.
As ``rosidl_cli`` is not yet available in ROS2 distributions (except ``rolling``), we would like to wait for it to be distributed.
See the upstream issue and design proposal for more details:

- Issue: https://github.com/ros2/rosidl/issues/565
- Proposal: https://github.com/ros2/design/pull/310
