from setuptools import find_packages, setup

setup(
    name="rosidl_generator_mypy",
    version="0.1.0",
    packages=find_packages(exclude=["tests"]),
    description="Generate stub files for the ROS2 interfaces in Python",
    long_description=open("README.rst").read(),
    author="Yuki Igarashi, Tamamki Nishino",
    author_email="me@bonprosoft.com, otamachan@gmail.com",
    classifiers=[
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: MacOS",
        "Operating System :: Microsoft :: Windows",
        "Operating System :: POSIX",
        "Operating System :: Unix",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python",
    ],
    license="Apache License 2.0",
    url="https://github.com/rospypi/rosidl_generator_mypy",
    include_package_data=True,
    zip_safe=False,
)
