# Dataclass for a waypoint on a track.
# Stored inside the track
extends Resource
class_name WaypointData

# Sequential identifier
@export var index: int
# Global space position of waypoint
@export var position: Vector3
# Weight between 0 and 1 which indicates how far along the track curve
@export var factor: float
