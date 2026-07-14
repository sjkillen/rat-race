extends VehicleBody3D


const MAX_STEER = 0.8 # 45 degrees limit on turn
const ENGINE_POWER = 300
var up_to_speed = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# Gets rid of mouse while playing
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Gradually steers car towards in desired direction
	steering = move_toward(steering, Input.get_axis("ui_right", "ui_left") * MAX_STEER, delta * 2.5)
	# Propel car forward
	engine_force = Input.get_axis("ui_down", "ui_up") * ENGINE_POWER
	
func _physics_process(delta: float) -> void:
	
	# Gets speed of car as int
	var fwd_mps = roundi(linear_velocity.length())
	
	# Updates speedometer
	get_node("../UI/Speedometer").text = "Speed: %s KPH" % fwd_mps
	
	if fwd_mps >= 50 and up_to_speed == false:
		up_to_speed = true
		print("Up to Speed!!")
	
	# Destroys car if player falls below threshold speed.
	if fwd_mps < 50 and up_to_speed == true:
		destroy_car()
	
func destroy_car() -> void:
	print("Too Slow!")
