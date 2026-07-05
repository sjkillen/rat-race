extends Node3D
class_name TrafficLight

@export var on_state: TrafficLightIntersection.LightState

func on_cycle_change(state: TrafficLightIntersection.LightState):
	var mat: StandardMaterial3D = %bulb.material_override
	mat.albedo_color = Color(1.0, 0.0, 0.0)
	if state == on_state:
		mat.albedo_color = Color(0.0, 1.0, 0.0)
