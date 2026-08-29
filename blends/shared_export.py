from pathlib import Path
import bpy
from bpy.types import Object, Armature, Modifier, Mesh, Context, Collection
from functools import reduce
from operator import attrgetter, itemgetter, or_

def project_path() -> Path:
    return Path(__file__).parent.parent.resolve()

def clear_selection():
    for obj in bpy.context.selected_objects:
        obj.select_set(False)

def select_collection(c: Collection):
    for obj in c.objects:
        obj.select_set(True)
