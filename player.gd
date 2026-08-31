extends VehicleBody3D
class_name Player

const MAX_STEER = 0.2  # 45 degrees limit on turn
const ENGINE_POWER = 500
const MIN_SPEED = 5
const SPEED_CUSHION = 10
const AUTOSTART_FORCE = MIN_SPEED + SPEED_CUSHION
var up_to_speed = false  # When true, allows player to die when below threshold

signal speedometer(msg: String)
signal speed_status(msg: String)
signal alive_status(is_alive: bool)

func _ready() -> void:
	linear_velocity = global_basis * Vector3.MODEL_FRONT * AUTOSTART_FORCE
	alive_status.emit(true)

@rpc("any_peer", "call_local")
func start_wait():
	%Camera3D.visible = false
	%Camera3D.current = false
	freeze = true

@rpc("any_peer", "call_local")
func start_race():
	switch_camera()
	freeze = false

func switch_camera():
	%Camera3D.visible = true
	%Camera3D.current = true

func _physics_process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("ui_right", "ui_left") * MAX_STEER, delta * .5)
	engine_force = Input.get_axis("ui_down", "ui_up") * ENGINE_POWER
	print(engine_force)

	var fwd_mps = roundi(linear_velocity.length())

	# Updates speedometer
	speedometer.emit("Speed: %s KPH" % fwd_mps)

	# Automatically accelerate the player into a safe speed
	if fwd_mps <= (MIN_SPEED + SPEED_CUSHION) and up_to_speed == false:
		# Disable the controls
		engine_force = 0.0
		# Uncomment to get rid of steering
		#steering = 0.0
		speed_status.emit("Accelerating...")

	# Once up to speed, change the flag and allow player to accelerate at will
	if fwd_mps >= (MIN_SPEED + SPEED_CUSHION) and up_to_speed == false:
		up_to_speed = true
		speed_status.emit("Up to Speed!")

	# Destroys car if player falls below threshold speed.
	if fwd_mps < MIN_SPEED and up_to_speed == true:
		destroy_car()

func destroy_car() -> void:
	alive_status.emit(false)
	linear_velocity = (Vector3.ZERO)
	speed_status.emit("Too Slow!")
