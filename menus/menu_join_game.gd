extends Control

var client: Client
var connection_timeout: Timer
const CONNECTING_MESSAGE := "Connecting..."
const TIMEOUT_MESSAGE := "Connection Timed Out"
const CONNECTION_SUCCESS_MESSAGE := "Connected Successfully"
const CONNECTION_FAILURE_MESSAGE := "Failed to Connect"

func _ready() -> void:
	if OS.has_feature("server_only"):
		get_tree().change_scene_to_file.call_deferred("res://multiplayer/CreateServer.tscn")

func join_game(address: String):
	client = preload("res://multiplayer/Client.tscn").instantiate()
	client.address = address
	client.online.connect(_on_connection_success)
	client.connection_error.connect(_on_connection_error)
	set_status_message(CONNECTING_MESSAGE)
	connection_timeout = Timer.new()
	add_child(connection_timeout)
	connection_timeout.timeout.connect(_on_connection_timeout)
	connection_timeout.start(5.0)
	Game.add_child(client)

func set_status_message(msg: String):
	%ConnectionStatusLabel.text = msg

func kill_connection_timeout():
	if connection_timeout == null:
		return
	remove_child(connection_timeout)
	connection_timeout = null

func kill_client():
	if client == null:
		return
	Game.remove_child(client)
	client = null

func restore_after_failure():
	kill_connection_timeout()
	kill_client()
	%ConnectButton.disabled = false
	
func _on_connection_timeout():
	set_status_message(TIMEOUT_MESSAGE)
	restore_after_failure()
	
func _on_connection_success():
	set_status_message(CONNECTION_SUCCESS_MESSAGE)
	kill_connection_timeout()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://multiplayer/game_room.tscn")

func _on_connection_error(_msg: String):
	set_status_message(CONNECTION_FAILURE_MESSAGE)
	restore_after_failure()

func _on_connect_button_pressed() -> void:
	var address: String = %IPAddressInput.text
	%ConnectButton.disabled = true
	join_game(address)

func _on_back_button_pressed() -> void:
	pass
