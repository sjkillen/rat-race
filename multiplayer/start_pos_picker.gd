extends Node3D
class_name StartPosPicker

const RAY_LENGTH := 1000
var mouse_on_track: bool = false
var mouse_position: Vector3

signal click_track(pos: Vector3)

# https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
func cast_ray_from_mouse() -> void:
	var space_state := get_world_3d().direct_space_state
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var mousepos := get_viewport().get_mouse_position()

	var origin := cam.project_ray_origin(mousepos)
	var end := origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	if result.has("position"):
		mouse_on_track = true
		mouse_position = result.get("position")
	else:
		mouse_on_track = false
		mouse_position = Vector3.ZERO
		
func _physics_process(_delta: float):
	cast_ray_from_mouse()

func _input(event: InputEvent) -> void:
	if not mouse_on_track:
		return
	if event is InputEventMouse and event.is_pressed() and event.button_mask == MOUSE_BUTTON_LEFT:
		click_track.emit(mouse_position)
