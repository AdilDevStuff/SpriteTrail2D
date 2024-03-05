@tool
extends Node2D

# Add a trail of copies of the parent's texture.
#
# Usage: put as a child of Sprite or Animated Sprite and tweek the settings in
# the inspector.
#
# Original Author: Luiz Lopes (youtube.com/CanalPalco)
# I just updated this to Godot 4.X. So, all thanks to Luiz for making this addon!

enum _ProcessMode {PROCESS, PHYSICS_PROCESS}

@export var active: bool = false: set = set_active, get = get_active
@export var life_time: = 0.6
@export var fake_velocity: = Vector2(0, 0)
@export var spawn_interval: = 0.2
@export var gradient: Gradient
@export var behind_parent: = true: set = set_behind_parent, get = get_behind_parent
@export var _process_mode: _ProcessMode = _ProcessMode.PROCESS: set = set_process_mode, get = get_process_mode

var _trail_copies: = []
var _elapsed_time: = 0.0

func _ready() -> void:
	show_behind_parent = behind_parent
	set_process_mode(process_mode)

func _process(delta: float) -> void:
	update_trail(delta, get_parent())

func _physics_process(delta: float) -> void:
	update_trail(delta, get_parent())

func _draw() -> void:
	for i in _trail_copies.size():
		var copy: Dictionary = _trail_copies[i]
		# We need to correct the direction if the scale is set to -1, see
		# spawn_copy method.
		var draw_translation: Vector2 = (to_local(copy.global_position) + get_parent().offset) * copy.transform_scale
		if get_parent().centered:
			draw_translation -= copy.texture.get_size() / 2.0

		var draw_transform = Transform2D(0.0, Vector2()) \
			.scaled(copy.transform_scale) \
			.translated(draw_translation)

		draw_set_transform_matrix(draw_transform)

		draw_texture(
			copy.texture,
			Vector2(),
			calculate_copy_color(copy)
		)

func process_copies(delta: float) -> void:
	var empty_copies: = _trail_copies.is_empty()

	for copy in _trail_copies:
		copy.remaining_time -= delta

		if copy.remaining_time <= 0:
			_trail_copies.erase(copy)
			continue

		copy.global_position -= fake_velocity * delta

	if not empty_copies:
		queue_redraw()

func get_texture(sprite: Node2D) -> Texture:
	if sprite is Sprite2D:
		if sprite.region_enabled:
			var new_texture = ImageTexture.new()
			var image = sprite.texture.get_data()
			var rect = sprite.region_rect
			image.resize(rect.size.x, rect.size.y)
			image.blit_rect(sprite.texture.get_data(), rect, Vector2.ZERO)
			new_texture.create_from_image(image)
			return new_texture
		else:
			return sprite.texture
	elif sprite is AnimatedSprite2D:
		return sprite.frames.get_frame(sprite.animation, sprite.frame)
	else:
		push_error("The SpriteTrail has to have a Sprite or an AnimatedSpriet as parent.")
		set_active(false)
		return null

func calculate_copy_color(copy: Dictionary) -> Color:
	if gradient:
		return gradient.sample(remap(copy.remaining_time, 0, life_time, 0, 1))

	return Color(1, 1, 1)

func spawn_copy(delta: int, parent: Node2D) -> void:
	var copy_texture: = get_texture(parent)
	var copy_position: Vector2

	if not copy_texture:
		return

	if parent.centered:
		copy_position = parent.global_position
	else:
		copy_position = parent.global_position

	# This is needed because the draw transform's scale is set to -1 on the flip
	# direction when the sprite is flipped
	var transform_scale: = Vector2(1, 1)
	
	## HACK: Removing these if statements fix some weird positioning of the trail
	#if parent.flip_h:
		#transform_scale.x = -1
	#if parent.flip_v:
		#transform_scale.y = -1

	var trail_copy: = {
		global_position = copy_position,
		texture = copy_texture,
		remaining_time = life_time,
		transform_scale = transform_scale,
	}
	_trail_copies.append(trail_copy)

func update_trail(delta: float, parent: Node2D) -> void:
	if active:
		_elapsed_time += delta

	process_copies(delta)

	if _elapsed_time > spawn_interval and active:
		spawn_copy(delta, parent)
		_elapsed_time = 0.0

func set_active(value: bool) -> void:
	active = value

func get_active():
	return active

func set_behind_parent(value: bool) -> void:
	behind_parent = value
	show_behind_parent = behind_parent

func get_behind_parent():
	return behind_parent

func set_process_mode(value: int) -> void:
	_process_mode = value

	set_process(_process_mode == _ProcessMode.PROCESS)
	set_physics_process(_process_mode == _ProcessMode.PHYSICS_PROCESS)

func get_process_mode():
	return _process_mode

func _get_configuration_warnings():
	if not (get_parent() is Sprite2D or get_parent() is AnimatedSprite2D):
		return ["This node has to be a child of a Sprite or an Animated Sprite to work."]
	return []
