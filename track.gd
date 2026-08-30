extends NavigationRegion3D
class_name Track

@export var num_waypoints: int = 10
@export var main_mesh: MeshInstance3D
# Points in global space on the track in main_mesh that mark waypoints
@onready var waypoints: Array[WaypointData] = create_waypoints()

func _ready() -> void:
	Game.track = self
	Game.delete_track.emit.call_deferred()
	Game.new_track.emit.call_deferred()

func nearest_waypoint(pos: Vector3) -> WaypointData:
	var min_dist = INF
	var nearest := waypoints[0]
	for p in waypoints:
		var dist := pos.distance_to(p.position)
		if dist < min_dist:
			nearest = p
			min_dist = dist
	return nearest

func track_direction(pos: Vector3) -> Vector3:
	var wp := nearest_waypoint(pos)
	var next_wp := waypoints[(wp.index + 1) % waypoints.size()]
	var delta := next_wp.position - wp.position
	delta.y = 0.0
	return delta
	
# Chooses num_waypoints based on how upward their normal is and how close they
# are to an even division of num_waypoints
# NOTE: the Blender export saves the track curve factor in 'UV.x'
func create_waypoints() -> Array[WaypointData]:
	var w := []
	w.resize(num_waypoints + 1)
	var mdt := MeshDataTool.new()
	mdt.create_from_surface(main_mesh.mesh, 0)
	var waypoint_length := 1.0 / num_waypoints
	for i in range(mdt.get_vertex_count()):
		var uv := mdt.get_vertex_uv(i)
		var normal := mdt.get_vertex_normal(i)
		var progress: int = floor(uv.x / waypoint_length)
		var progress_rem := fmod(uv.x, waypoint_length)
		var upwardness: float = abs(Vector3.UP.dot(normal) - 1.0)
		var score = progress_rem + upwardness
		if w[progress] == null or w[progress][0] > score:
			w[progress] = [score, mdt.get_vertex(i), uv.x]
	var ww: Array[WaypointData] = []
	for item in w:
		if item == null:
			continue
		var data := WaypointData.new()
		data.index = ww.size()
		data.position = main_mesh.global_transform * item[1]
		data.factor = item[2]
		ww.append(data)
	return ww
	
