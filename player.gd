extends VehicleBody3D
class_name Player

const MAX_STEER = 0.8  # 45 degrees limit on turn
const ENGINE_POWER = 300
const AUTOSTART_FORCE = 65
var up_to_speed = false  # When true, allows player to die when below threshold


signal speedometer(msg: String)
signal speed_status(msg: String)
signal alive_status(is_alive: bool)

func _ready() -> void:
	linear_velocity = global_basis * Vector3.MODEL_FRONT * AUTOSTART_FORCE
	alive_status.emit(true)

func _process(delta: float) -> void:
	
	steering = move_toward(steering, Input.get_axis("ui_right", "ui_left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("ui_down", "ui_up") * ENGINE_POWER

	var fwd_mps = roundi(linear_velocity.length())
	
	# Updates speedometer
	speedometer.emit("Speed: %s KPH" % fwd_mps)
	
	# Automatically accelerate the player into a safe speed
	# TODO: Figure out how to disable/re-enable inputs properly during the acceleration phase instead of killing the forces
	if fwd_mps <= 60 and up_to_speed == false:
		# Disable the controls
		engine_force = 0.0
		# Uncomment to get rid of steering
		#steering = 0.0
		speed_status.emit("Accelerating...")
	
	# Once up to speed, change the flag and allow player to accelerate at will
	if fwd_mps >= 60 and up_to_speed == false:
		up_to_speed = true
		speed_status.emit("Up to Speed!")
	
	# Destroys car if player falls below threshold speed.
	if fwd_mps < 50 and up_to_speed == true:
		destroy_car()
	
func destroy_car() -> void:
	alive_status.emit(false)
	linear_velocity = (Vector3.ZERO)
	speed_status.emit("Too Slow!")
