extends CharacterBody3D

const SPEED: float = 1.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if %NavigationAgent3D.is_navigation_finished():
		move_and_slide()
		return
	var target: Vector3 = %NavigationAgent3D.get_next_path_position()
	var target_dir := target - global_position
	target_dir.y = 0.0
	velocity += target_dir.normalized() * SPEED * delta
	move_and_slide()
