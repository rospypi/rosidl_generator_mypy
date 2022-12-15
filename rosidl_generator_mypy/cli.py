import pathlib

from ament_index_python import get_package_share_directory
from rosidl_cli.command.generate.extensions import GenerateCommandExtension
from rosidl_cli.command.helpers import legacy_generator_arguments_file
from rosidl_cli.command.translate.api import translate

from rosidl_generator_mypy import generate


class GenerateMypy(GenerateCommandExtension):

    def generate(
        self,
        package_name,
        interface_files,
        include_paths,
        output_path
    ):
        generated_files = []

        package_share_path = \
            pathlib.Path(get_package_share_directory('rosidl_generator_mypy'))
        templates_path = package_share_path / 'resource'

        # Normalize interface definition format to .idl
        idl_interface_files = []
        non_idl_interface_files = []
        for path in interface_files:
            if not path.endswith('.idl'):
                non_idl_interface_files.append(path)
            else:
                idl_interface_files.append(path)
        if non_idl_interface_files:
            idl_interface_files.extend(translate(
                package_name=package_name,
                interface_files=non_idl_interface_files,
                include_paths=include_paths,
                output_format='idl',
                output_path=output_path / 'tmp',
            ))

        # Generate code
        with legacy_generator_arguments_file(
            package_name=package_name,
            interface_files=idl_interface_files,
            include_paths=include_paths,
            templates_path=templates_path,
            output_path=output_path
        ) as path_to_arguments_file:
            generated_files.extend(generate(path_to_arguments_file))

        return generated_files
