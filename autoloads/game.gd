extends Node

func server() -> Server:
	var room = room()
	if room == null or not room.multiplayer.is_server():
		return null
	return room as Server

func client() -> Client:
	var room = room()
	if room == null or room.multiplayer.is_server():
		return null
	return room as Client

func room():
	return get_node_or_null("ServerClientShared")
