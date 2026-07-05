extends CharacterBody3D
class_name NPCDriver

const SPEED: float = 10
var current_waypoint: WaypointData
var direction := Direction.Higher
var granted_passage: bool = false
var stopped_reasons := []
signal waypoint_reached(this: NPCDriver, waypoint: WaypointData)

enum Direction {
	Higher,
	Lower,
}

# https://kidscancode.org/godot_recipes/4.x/3d/3d_align_surface/index.html
func align_with_yz(basis1: Basis, new_y: Vector3, new_z: Vector3):
	var basis2 := Basis()
	basis2.y = new_y
	basis2.z = new_z
	basis2.x = -new_z.cross(new_y)
	basis2 = basis2.orthonormalized()
	if basis2.is_orthonormal():
		return basis2
	else:
		return basis1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return
	
	var target: Vector3 = %NavigationAgent3D.get_next_path_position()
	var target_dir := target - global_position
	target_dir.y = 0.0
	target_dir = target_dir.normalized()
	if is_on_floor():
		global_basis = align_with_yz(global_basis, get_floor_normal(), target_dir)
	if %NavigationAgent3D.is_navigation_finished():
		move_and_slide()
		return
	velocity = target_dir * SPEED 
	if is_stopped():
		velocity = Vector3.ZERO
	move_and_slide()

func set_waypoint(waypoint: WaypointData):
	current_waypoint = waypoint
	nav_to(waypoint.position)

func nav_to(pos: Vector3) -> void:
	%NavigationAgent3D.target_position = pos

func _on_navigation_agent_3d_navigation_finished() -> void:
	waypoint_reached.emit(self, current_waypoint)

func is_stopped() -> bool:
	if granted_passage:
		return false
	return stopped_reasons.size() > 0

func stop_for(why):
	if stopped_reasons.has(why):
		return
	if why is NPCDriver and why.direction != direction:
		return
	stopped_reasons.append(why)
	for body in %StopField.get_overlapping_bodies():
		if body is not NPCDriver:
			continue
			body.stop_for(self)

func resume_for(why):
	var i := stopped_reasons.find(why)
	if i == -1:
		return
	while true:
		stopped_reasons.remove_at(i)
		i = stopped_reasons.find(why)
		if i == -1:
			break
	if is_stopped():
		return
	for body in %StopField.get_overlapping_bodies():
		if body is NPCDriver:
			body.resume_for(self)

func _on_stop_field_body_entered(body: Node3D) -> void:
	if is_stopped() and body is NPCDriver:
		body.stop_for(self)

func _on_stop_field_body_exited(body: Node3D) -> void:
	if body is NPCDriver:
		body.resume_for(self)
