@abstract
extends Node
class_name ServerClient

@export var port := 4547
@onready var npc_driver_manager: NPCDriverManager = %NPCDriverManager

signal player_joined(id: int, node: Player)
signal local_player_joined(node: Player)

func _ready() -> void:
	%PlayerSpawner.set_spawn_function(on_player_spawn)
	player_joined.connect(on_player_joined)

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
