extends Area3D
class_name TrafficLightIntersection

const waypoint_epsilon := 10.0
const grace_time: float = 1.0
@export var light_state: LightState = LightState.Low
@export var wait_time: float = 3.0
@export var stop_time: float = 1.0
@export var track: Track
@onready var factor_midpoint := compute_factor_midpoint()

var timer: Timer

enum LightState {
	Low,
	High,
	Off,
}

signal cycle_change(state: LightState)

func _ready() -> void:
	timer = Timer.new()
	get_tree().root.add_child.call_deferred(timer)
	get_tree().create_timer(wait_time).timeout.connect(_on_timeout)
	for light in lights():
		cycle_change.connect(light.on_cycle_change)

# Find two waypoints within waypoint_epsilon distance
# then compute their average factor
func compute_factor_midpoint() -> float:
	var low_waypoint: WaypointData = null
	var high_waypoint: WaypointData = null
	for waypoint in track.waypoints:
		if waypoint.position.distance_to(global_position) > waypoint_epsilon:
			continue
		if low_waypoint == null:
			low_waypoint = waypoint
		if high_waypoint == null:
			high_waypoint = waypoint		
		if waypoint.factor < low_waypoint.factor:
			low_waypoint = waypoint
		elif waypoint.factor > high_waypoint.factor:
			high_waypoint = waypoint
	if low_waypoint == null or high_waypoint == null:
		push_error("Failed to compute midpoint")
		return 0.0
	return (low_waypoint.factor + high_waypoint.factor) / 2.0

func lights() -> Array[TrafficLight]:
	var result: Array[TrafficLight]
	for child in get_children():
		if child is TrafficLight:
			result.append(child)
	return result

func toggle_light_state():
	if light_state == LightState.Low:
		light_state = LightState.High
	else:
		light_state = LightState.Low

func _on_timeout():
	var old_state = light_state
	light_state = LightState.Off
	cycle_change.emit(light_state)
	await get_tree().create_timer(stop_time).timeout
	light_state = old_state
	toggle_light_state()
	cycle_change.emit(light_state)
	get_tree().create_timer(wait_time).timeout.connect(_on_timeout)

func npc_should_stop(who: NPCDriver) -> bool:
	if light_state == LightState.Off:
		return true
	var cond := who.current_waypoint.factor < factor_midpoint
	if light_state == LightState.Low:
		cond = not cond
	return cond

func direct_npc(who: NPCDriver):
	if npc_should_stop(who):
		who.stop_for(self)
	else:
		who.resume_for(self)

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is NPCDriver:
			direct_npc(body)

func _on_body_entered(body: Node3D) -> void:
	if body is NPCDriver:
		direct_npc(body)

func _on_granted_passage_body_entered(body: Node3D) -> void:
	if body is NPCDriver:
		body.granted_passage = true

func _on_body_exited(body: Node3D) -> void:
	if body is NPCDriver:
		body.resume_for(self)
		await get_tree().create_timer(grace_time).timeout
		body.granted_passage = false
