extends ServerClient
class_name Server

var is_online: bool = true
signal online

func _ready() -> void:
	super()
	create_server()

func create_server():
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port)
	if err != OK:
		printerr("Failed to create server: ", error_string(err))
		return
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(on_peer_online)
	peer.peer_disconnected.connect(on_peer_offline)
	print("Server listening with IPv4 and IPv6 on port ", port)
	online.emit.call_deferred()

func on_peer_online(who: int):
	print("Peer connected: ", who)
	on_player_connect.rpc(who)
		
func on_peer_offline(who: int):
	print("Peer disconnected: ", who)
	var player: Player = %Players.get_node_or_null(str(who))
	%Players.remove_child(player)
	on_player_disconnect.rpc(who)
	
