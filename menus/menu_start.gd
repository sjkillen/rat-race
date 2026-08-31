extends Control

func _ready() -> void:
	if OS.has_feature("server_only"):
		print("Starting server...")
		get_tree().change_scene_to_file.call_deferred("res://multiplayer/CreateServer.tscn")

func _on_join_game_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/menu_join_game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
