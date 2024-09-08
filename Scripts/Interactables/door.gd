extends Node3D

@export var animation_player: AnimationPlayer
@export var highlight_material: StandardMaterial3D
@export var text : Label3D
@export var image : Sprite3D
@export var interactable : Interactable

@onready var chest_meshinstance: MeshInstance3D = $Hinge/wall_doorway_door
@onready var chest_material: StandardMaterial3D = chest_meshinstance.mesh.surface_get_material(0)



var is_open: bool = false

func _ready():
	text.visible = false
	image.visible = false
	pass

func close() -> void:
	is_open = false
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Hinge, "rotation_degrees", Vector3.ZERO, 0.3).set_ease(Tween.EASE_OUT)

func open_inward() -> void:
	_open_to_rotation(90)

func open_outward() -> void:
	_open_to_rotation(-90)

func _open_to_rotation(to_rotation: float = 90) -> void:
	is_open = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Hinge, "rotation_degrees", Vector3(0, to_rotation, 0), 0.3).set_ease(Tween.EASE_OUT)

func open_away_from(opener_position: Vector3) -> void:
	is_open = true
	var direction: Vector3 = global_position.direction_to(opener_position)
	var forward_vector: Vector3 = Vector3.RIGHT.rotated(Vector3.UP, global_rotation.y)
	var angle: float = direction.dot(forward_vector)

	if angle > 0:
		print("inward ", angle)
		open_inward()
	else:
		print("outward ", angle)
		open_outward()

func add_highlight() -> void:
	chest_meshinstance.set_surface_override_material(0, chest_material.duplicate())
	chest_meshinstance.get_surface_override_material(0).next_pass = highlight_material
	
	text.visible = true
	text.text = interactable.interactions[0]

	image.visible = true
	image.texture = load(key_dict.new().keyboard.F)

func remove_highlight() -> void:
	chest_meshinstance.set_surface_override_material(0, null)
	var interactable_text : Label3D = get_node("Hinge/Interactable/text")
	interactable_text.visible = false
	image.visible = false

func _on_interactable_focused(interactor: Interactor) -> void:
	add_highlight()
	pass # Replace with function body.

func _on_interactable_unfocused(interactor: Interactor) -> void:
	remove_highlight()
	pass # Replace with function body.

func _on_interactable_interacted(interactor: Interactor) -> void:

	if is_open:
		print("closing")
		close()
	else:
		print("opening")
		open_away_from(interactor.controller.global_position)
