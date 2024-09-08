extends RayCast3D

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	if is_colliding():
		var hit_object = get_collider()
		# print(get_collider().name)
		if hit_object.has_method("interact") && Input.is_action_just_pressed("Interact"):
			hit_object.interact()