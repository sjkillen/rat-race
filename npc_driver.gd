extends CharacterBody3D

const SPEED: float = 1.0

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
	
	var target: Vector3 = %NavigationAgent3D.get_next_path_position()
	var target_dir := target - global_position
	target_dir.y = 0.0
	target_dir = target_dir.normalized()
	if is_on_floor():
		global_basis = align_with_yz(global_basis, get_floor_normal(), target_dir)
	if %NavigationAgent3D.is_navigation_finished():
		move_and_slide()
		return
	velocity += target_dir * SPEED * delta
	move_and_slide()
