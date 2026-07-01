"""
Common .blend exporting functions to be used by .blend file text blocks (See README.md)
"""

from functools import reduce
from operator import attrgetter, itemgetter, or_
from pathlib import Path

import bpy
from bpy.types import Armature, Collection, Context, Mesh, Modifier, Object


def project_path() -> Path:
    return Path(__file__).parent.parent.resolve()


def clear_selection():
    for obj in bpy.context.selected_objects:
        obj.select_set(False)


def select_collection(c: Collection):
    for obj in c.objects:
        obj.select_set(True)
