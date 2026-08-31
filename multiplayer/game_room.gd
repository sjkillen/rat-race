extends Node3D

var player: Player

func _ready() -> void:
	var client: Client = Game.client()
	if client != null:
		init_client(client)
	var server: Server = Game.server()
	if server != null:
		init_server(server)

func init_client(client: Client):
	client.local_player_joined.connect(set_player)
	client.start_pos_picker.click_track.connect(pick_spawn)
	client.spawn_player()
	%Waiting.enable_waiting()
	client.waiting_timer_tick.connect(%Waiting.update_timer)
	client.game_state_change.connect(client_gamestatechange.bind(client))
	
func client_gamestatechange(client: Client):
	if client.game_state == ServerClient.GameState.RACING:
		%Waiting.disable_waiting()
		player.start_race()

func set_player(p: Player):
	player = p

func pick_spawn(pos: Vector3):
	if player != null:
		pos.y += 1.5
		print(pos)
		player.global_position = pos
		var dir := -Game.track.track_direction(pos)
		player.global_basis = Basis.looking_at(dir)
		

func init_server(server: Server):
	Game.new_track.connect(spawn_npc_drivers.bind(server))
	%Waiting.disable_waiting()

func spawn_npc_drivers(server: Server):
	server.npc_driver_manager.created_distributed_drivers(100)
