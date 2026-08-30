extends Control

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Retry.visible = false
	if player == null:
		push_error("Missing player on debug UI...")
		return
	player.speedometer.connect(player_speedometer)
	player.speed_status.connect(player_speed_status)
	player.alive_status.connect(player_alive_status)

func player_speedometer(msg: String):
	%Speedometer.text = msg

func player_speed_status(msg: String):
	%SpeedStatus.text = msg

func player_alive_status(is_alive: bool):
	%Retry.visible = not is_alive

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and %Retry.visible:
		get_tree().reload_current_scene()
