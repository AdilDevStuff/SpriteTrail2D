extends Node2D

@export var speed: = 300

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	$Sprite2D/SpriteTrail2D.active = true

func _physics_process(delta: float) -> void:
	var direction: = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction.x < 0:
		sprite.flip_h = true
	elif direction.x > 0:
		sprite.flip_h = false

	translate(direction * speed * delta)
