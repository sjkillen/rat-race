extends Node

func _ready() -> void:
	var server: Server = preload("res://multiplayer/Server.tscn").instantiate()
	Game.add_child(server)
	get_tree().change_scene_to_file("res://multiplayer/game_room.tscn")
