extends VehicleBody3D


const MAX_STEER = 0.8  # 45 degrees limit on turn
const ENGINE_POWER = 300
const AUTOSTART_FORCE = 65
var up_to_speed = false  # When true, allows player to die when below threshold


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("../UI/Retry").hide()
	linear_velocity = global_basis * Vector3.MODEL_FRONT * AUTOSTART_FORCE

	# Gets rid of mouse while playing
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Gradually steers car towards in desired direction
	steering = move_toward(steering, Input.get_axis("ui_right", "ui_left") * MAX_STEER, delta * 2.5)
	# Player propels car forward
	engine_force = Input.get_axis("ui_down", "ui_up") * ENGINE_POWER

	# Gets speed of car as int
	var fwd_mps = roundi(linear_velocity.length())
	
	# Updates speedometer
	# TODO: Getting the node every frame is inefficient, no? Fix
	get_node("../UI/Speedometer").text = "Speed: %s KPH" % fwd_mps
	
	# Automatically accelerate the player into a safe speed
	# TODO: Figure out how to disable/re-enable inputs properly during the acceleration phase instead of killing the forces
	if fwd_mps <= 60 and up_to_speed == false:
		# Disable the controls
		engine_force = 0.0
		# Uncomment to get rid of steering
		#steering = 0.0
		get_node("../UI/SpeedStatus").text = "Accelerating..."
	
	# Once up to speed, change the flag and allow player to accelerate at will
	if fwd_mps >= 60 and up_to_speed == false:
		up_to_speed = true
		get_node("../UI/SpeedStatus").text = "Up to Speed!"
	
	# Destroys car if player falls below threshold speed.
	if fwd_mps < 50 and up_to_speed == true:
		destroy_car()
	
func destroy_car() -> void:
	get_node("../UI/Retry").show()
	linear_velocity = (Vector3.ZERO)
	#get_node("../UI/SpeedStatus").text = "Too Slow!"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and get_node("../UI/Retry").visible:
		get_tree().reload_current_scene()
