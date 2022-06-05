extends Node

signal join(player_id)
signal set_player_name(player_id, player_name)
signal set_is_ready(player_id, is_ready)
signal set_character_id(player_id, character_id)
signal set_scene_id(player_id, scene_id)
signal set_question(question, answers)
signal reveal_answer(correct_answer_index)
signal set_colour_id(player_id, colour_id)
signal send_all_player_data(player_data)
signal set_player_score(player_id,score)

var websocket_url = "ws://{SERVER_HOST}:{SERVER_PORT}/{SERVER_PATH}".format(
	{
		"SERVER_HOST": Global.server_host,
		"SERVER_PORT": Global.server_port,
		"SERVER_PATH": "server/host" if Global.is_production else "host",
	}
)
var websocket_client = WebSocketClient.new()
var json = JSON.new()


func _ready() -> void:
	# Connect base signals to get notified of connection open, close, and errors
	websocket_client.connection_closed.connect(self._on_connection_closed)
	websocket_client.connection_error.connect(self._on_connection_closed)
	websocket_client.connection_established.connect(self._on_connection_connected)
	websocket_client.data_received.connect(self._on_data_received)

	# Initiate connection to the given URL
	print(
		"Connecting to websocket URL {websocket_url}".format(
			{"websocket_url": websocket_url}
		)
	)
	var err = websocket_client.connect_to_url(websocket_url)
	if err:
		print("Unable to connect")
		set_process(false)

	# Write text instead of binary
	websocket_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)


func _on_connection_closed(was_clean = false) -> void:
	# was_clean will tell you if the disconnection was correctly notified by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)


func _on_connection_connected(proto = "") -> void:
	print("Connected with protocol: ", proto)
	emit_signal("set_scene_id", "character_selection_menu")


func _on_data_received() -> void:
	# Parse data to string
	var data_str: String = websocket_client.get_peer(1).get_packet().get_string_from_utf8()

	# Parse string to JSON
	var err = json.parse(data_str)
	if err:
		print("Oh no!", json.get_error_message())
		return
	var data = json.get_data()
	print("Got data from server: ", json.stringify(data))

	# Take action based on message
	match data.action:
		"join":
			emit_signal("join", data.player_id)
		"set_player_name":
			emit_signal("set_player_name", data.player_id, data.player_name)
		"set_is_ready":
			emit_signal("set_is_ready", data.player_id, data.is_ready)
		"set_character_id":
			emit_signal("set_character_id", data.player_id, data.character_id)
		"set_colour_id":
			emit_signal("set_colour_id", data.player_id, data.colour_id)
		"set_scene_id":
			emit_signal("set_scene_id", data.scene_id)
		"set_question":
			emit_signal("set_question", data.question, data.answers)
		"reveal_answer":
			emit_signal("reveal_answer", data.correct_answer_index)
		"send_all_player_data":
			emit_signal("send_all_player_data", data.player_data)
		"set_player_score":
			emit_signal("set_player_score", data.player_id, data.score)
		_:
			print("Unknown action: ", data)


func _process(_delta: float) -> void:
	websocket_client.poll()


func _send_message_to_server(message_data: Dictionary) -> void:
	var message_string = json.stringify(message_data)
	print("Sending message to server: ", message_string)
	websocket_client.get_peer(1).put_packet(message_string.to_utf8_buffer())


func _on_get_question() -> void:
	_send_message_to_server({"action": "get_question"})


func _on_get_all_player_data() -> void:
	_send_message_to_server({"action": "get_all_player_data"})
