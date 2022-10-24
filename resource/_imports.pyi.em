@# Included from rosidl_generator_mypy/resource/*.pyi.em
@{
third_party_imports = set()
first_party_imports = set()
generator(component, defined_classes, third_party_imports, first_party_imports)

import sys
python_minor_version = sys.version_info.minor
}@

import typing
@[if python_minor_version < 10]@
from typing_extensions import TypeAlias
@[else]@
from typing import TypeAlias
@[end if]

import array
import numpy as np

@[if len(third_party_imports) > 0]@

@[for statement in sorted(third_party_imports)]@
@(statement)
@[end for]@
@[  end if]@
@[if len(first_party_imports) > 0]@

@[for statement in sorted(first_party_imports)]@
@(statement)
@[end for]@
@[  end if]@
