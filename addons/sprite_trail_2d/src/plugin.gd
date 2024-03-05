@tool
extends EditorPlugin

var type_name: String = "SpriteTrail2D"
var sprite_trail_2d: Script = preload("../src/SpriteTrail2D.gd")
var plugin_icon: Texture2D = preload("../assets/sprite_trail_2d_icon.png")

func _enter_tree() -> void:
	add_custom_type(type_name, "Node2D", sprite_trail_2d, plugin_icon)

func _exit_tree() -> void:
	remove_custom_type(type_name)
