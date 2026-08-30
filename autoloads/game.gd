extends Node

func server() -> Server:
	var room = serverclient()
	if room == null or not room.multiplayer.is_server():
		return null
	return room as Server

func client() -> Client:
	var room = serverclient()
	if room == null or room.multiplayer.is_server():
		return null
	return room as Client

func serverclient():
	return get_node_or_null("ServerClientShared")

func go_offline():
	var room = serverclient()
	if room != null:
		remove_child(room)
