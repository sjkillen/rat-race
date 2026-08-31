@abstract
extends Node
class_name ServerClient

enum GameState {
	EMPTY,
	WAITING,
	RACING,
}

const WAITING_TIME = 10.0
var game_state: GameState = GameState.EMPTY
@export var port := 4547
@onready var npc_driver_manager: NPCDriverManager = %NPCDriverManager

signal player_joined(id: int, node: Player)
signal local_player_joined(node: Player)
signal game_state_change
signal waiting_timer_tick(wait_time: float)

var connected_players := 0

func _ready() -> void:
	%WaitingTimer.timeout.connect(state_transition)
	%PlayerSpawner.set_spawn_function(on_player_spawn)
	player_joined.connect(on_player_joined)

@rpc("authority", "call_local")
func enter_EMPTY() -> GameState:
	game_state = GameState.EMPTY
	kill_waiting_timer()
	return GameState.EMPTY

@rpc("authority", "call_local")
func enter_WAITING() -> GameState:
	game_state = GameState.WAITING
	reset_waiting_timer()
	return GameState.WAITING

@rpc("authority", "call_local")
func enter_RACING() -> GameState:
	game_state = GameState.RACING
	kill_waiting_timer()
	return GameState.RACING

func state_transition():
	if not is_multiplayer_authority():
		return
	var old_state := game_state
	if connected_players == 0:
		enter_EMPTY.rpc()
	if game_state == GameState.EMPTY and connected_players > 0:
		enter_WAITING.rpc()
	#if game_state == GameState.RACING and connected_players == 1:
		#enter_WAITING.rpc()
	# TODO winner
	if game_state == GameState.WAITING and %WaitingTimer.time_left == 0.0:
		enter_RACING.rpc()
	if game_state != old_state:
		print("Game state changed to ", GameState.keys()[game_state])
		announce_game_state_change.rpc()
	else:
		print("Game state stayed ", GameState.keys()[game_state])

@rpc("authority", "call_local")
func announce_game_state_change():
	game_state_change.emit()

func kill_waiting_timer():
	%WaitingTimer.stop()
	
func reset_waiting_timer():
	%WaitingTimer.start(WAITING_TIME)
	
func _process(_delta: float) -> void:
	if not %WaitingTimer.is_stopped():
		waiting_timer_tick.emit(%WaitingTimer.time_left)

@rpc("authority", "call_local")
func on_player_connect(_who: int):
	connected_players += 1
	if game_state == GameState.WAITING:
		%WaitingTimer.start(WAITING_TIME)
	state_transition()

@rpc("authority", "call_local")
func on_player_disconnect(_who: int):
	connected_players -= 1
	state_transition()

@rpc("any_peer")
func spawn_player():
	if not multiplayer.is_server():
		spawn_player.rpc_id(1)
		return
	var source := multiplayer.get_remote_sender_id()
	%PlayerSpawner.spawn(source)

func on_player_joined(id: int, node: Player):
	if id == multiplayer.get_unique_id():
		local_player_joined.emit(node)

func on_player_spawn(player_id: int):
	var node: Player = preload("res://shark/shark.tscn").instantiate()
	node.name = str(player_id)
	node.set_multiplayer_authority(player_id, true)
	node.connect("tree_entered", player_joined.emit.bind(player_id, node), CONNECT_ONE_SHOT)
	return node
