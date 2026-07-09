extends "./server_client_shared.gd"

var address: String = "::1"

var is_online: bool = false
# Duplicated in client/server to avoid weird bug with connecting signals in the inspector
signal online
signal offline

func _ready() -> void:
	super()
	join_server()

func join_server():
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		printerr("Failed to join server: ", error_string(err))
		return
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(on_peer_online)
	peer.peer_disconnected.connect(on_peer_offline)
	print("Joining server [", address, "]:", port)
	await online
	print("Joined Server!")
	
func on_peer_online(who: int):
	print("Peer connected: ", who)
	if who == 1:
		online.emit()

func on_peer_offline(who: int):
	print("Peer disconnected: ", who)
	if who == 1:
		offline.emit()

func _on_online() -> void:
	is_online = true

func _on_offline() -> void:
	is_online = false
