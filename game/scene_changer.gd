extends Node

@onready var child_scene
@onready var websocket_client = $"WebsocketClient"


func _ready() -> void:
	websocket_client.set_scene_id.connect(self._on_set_scene_id)


func _on_set_scene_id(scene_id: String) -> void:
	var scene_resource
	match scene_id:
		"character_selection_menu":
			scene_resource = preload("res://character_selection_menu/character_selection_menu.tscn")
		"game":
			scene_resource = preload("res://game/game.tscn")
	replace_current_node(scene_resource)


func replace_current_node(new_scene) -> void:
	var new_node = new_scene.instantiate()
	new_node.websocket_client = websocket_client
	if child_scene:
		remove_child(child_scene)
		child_scene.call_deferred("free")
	add_child(new_node)
	child_scene = new_node
