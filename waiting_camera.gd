extends Node3D

const SPEED := 10.0
@export var player: Player

func set_current():
	%Camera3D.current = true

func unset_current():
	%Camera3D.current = false


func _process(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var d := dir * SPEED * delta
	position.x += d.x * 3.0
	position.z += d.y * 1.75
