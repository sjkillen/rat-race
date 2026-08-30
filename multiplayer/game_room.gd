extends Node3D

func _ready() -> void:
	var client: Client = Game.client()
	if client != null:
		client.spawn_player()
	
