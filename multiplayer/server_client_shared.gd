@abstract
extends Node
class_name ServerClient

@export var port := 4547

signal player_joined(id: int, node: Node3D)

func _ready() -> void:
	%PlayerSpawner.set_spawn_function(on_player_spawn)

@rpc("any_peer")
func spawn_player():
	if not multiplayer.is_server():
		push_error("Only the server can spawn players, not ", multiplayer.get_unique_id())
		return
	var source := multiplayer.get_remote_sender_id()
	%PlayerSpawner.spawn(source)

func on_player_spawn(player_id: int):
	var node := preload("../tests/test_player.tscn").instantiate()
	node.name = str(player_id)
	node.set_multiplayer_authority(player_id, true)
	node.connect("tree_entered", player_joined.emit.bind(player_id, node), CONNECT_ONE_SHOT)
	return node
