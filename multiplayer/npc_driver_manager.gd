extends Node3D
class_name NPCDriverManager

func _ready() -> void:
	%NPCDriverSpawner.set_spawn_function(on_npc_spawn)
	Game.delete_track.connect(delete_track)

func created_distributed_drivers(num_drivers: int):
	if Game.track == null:
		push_error("No track loaded")
		return
	var inc: int = floor(Game.track.waypoints.size() / num_drivers)
	for i in range(0, Game.track.waypoints.size(), inc):
		%NPCDriverSpawner.spawn(i)

func on_npc_spawn(i: int):
	var node: NPCDriver = preload("res://npc_driver.tscn").instantiate()
	if multiplayer.is_server():
		node.connect("tree_entered", initialize_driver.bind(node, i), CONNECT_ONE_SHOT)
	return node

func initialize_driver(driver: NPCDriver, i: int):
	var waypoint: WaypointData = Game.track.waypoints[i]
	driver.waypoint_reached.connect(driver_reached_waypoint)
	driver.global_position = waypoint.position
	driver.set_waypoint(waypoint)

func driver_reached_waypoint(who: NPCDriver, waypoint: WaypointData):
	var next_waypoint = (waypoint.index + 1) % Game.track.waypoints.size()
	who.set_waypoint(Game.track.waypoints[next_waypoint])

func delete_track():
	if not multiplayer.is_server():
		return
	for driver in %NPCDrivers.get_children():
		print("Driver deleted...")
		driver.queue_free()
