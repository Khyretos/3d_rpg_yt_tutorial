extends CharacterBody3D

@onready var animation_tree = get_node("AnimationTree")
@onready var playback = animation_tree.get("parameters/playback")

@onready var player_mesh = get_node("Knight")

@export var gravity: float = 9.8
@export var jump_force: int = 9
@export var walk_speed: int = 3
@export var run_speed: int = 10

#animate Node Names
var idle_node_name: String = "Idle"
var walk_node_name: String = "Walk"
var run_node_name: String = "Run"
var jump_node_name: String = "Jump"
var attack1_node_name: String = "Attack1"
var death_node_name: String = "Death_A"

#State Machine conditions
var is_attacking: bool
var is_walking: bool
var is_running: bool
var is_dying: bool

#Physics values
var direction: Vector3
var horizontal_velocity: Vector3
var aim_turn: float
var movement: Vector3
var vertical_velocity: Vector3
var movement_speed: int
var angular_acceleration: int
var acceleration: int
var just_hit: bool = false

@onready var camera_rotation_horizontal = get_node("CameraRotation/CameraPosition")

func _ready() -> void:
	direction = Vector3.BACK.rotated(Vector3.UP, get_node("CameraRotation/CameraPosition").global_transform.basis.get_euler().y)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# animate the player with the mouse movement while aiming
		aim_turn = -event .relative.x * 0.015
	if event.is_action_pressed("Aim"):
		direction = get_node("CameraRotation/CameraPosition").global_transform.basis.z

func _physics_process(delta: float) -> void:

	var on_floor = is_on_floor()

	# rotate player
	if !is_dying:
		attack1()
		if !is_on_floor():
			vertical_velocity += Vector3.DOWN * gravity * 2 * delta
		else:
			vertical_velocity = Vector3.DOWN * gravity / 10
		
		if Input.is_action_just_pressed("Jump") and (!is_attacking) and is_on_floor():
			vertical_velocity = Vector3.UP * jump_force

		angular_acceleration = 10
		movement_speed = 0
		acceleration = 15
		
		if attack1_node_name in playback.get_current_node():
			is_attacking = true
		else:
			is_attacking = false

		var horizontal_rotation = camera_rotation_horizontal.global_transform.basis.get_euler().y
		
		if (Input.is_action_pressed("Forward") || Input.is_action_pressed("Backward") || Input.is_action_pressed("Left") || Input.is_action_pressed("Right")):
			#why
			direction = Vector3(Input.get_action_strength("Left") - Input.get_action_strength("Right"), 0 , Input.get_action_strength("Forward") - Input.get_action_strength("Backward"))
			direction = direction.rotated(Vector3.UP, horizontal_rotation).normalized()
			
			if Input.is_action_pressed("Sprint") and (is_walking):
				movement_speed = run_speed
				is_running = true
			else:
				movement_speed = walk_speed
				is_walking = true
				is_running = false
		else:
			is_walking = false
			is_running = false
		
		if Input.is_action_pressed("Aim"):
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, camera_rotation_horizontal.rotation.y, delta * angular_acceleration)
		else:
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * acceleration)

		if is_attacking:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized() * 0.1, acceleration * delta)
		else:
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized() * movement_speed, acceleration * delta)

		velocity.z = horizontal_velocity.z + vertical_velocity.z
		velocity.x = horizontal_velocity.x + vertical_velocity.x
		velocity.y = vertical_velocity.y

		move_and_slide()

	animation_tree["parameters/conditions/is_on_floor"] = on_floor
	animation_tree["parameters/conditions/is_in_air"] = !on_floor
	animation_tree["parameters/conditions/is_walking"] = is_walking
	animation_tree["parameters/conditions/is_not_walking"] = !is_walking
	animation_tree["parameters/conditions/is_running"] = is_running
	animation_tree["parameters/conditions/is_not_running"] = !is_running
	animation_tree["parameters/conditions/is_dying"] = is_dying


func attack1():
	# to add attacking while running just add another or.
	if (idle_node_name in playback.get_current_node()) or (walk_node_name in playback.get_current_node()) :
		pass
		if Input.is_action_just_pressed("Attack"):
			if !is_attacking:
				#manually trigger (travel) animation
				playback.travel(attack1_node_name)


func _on_collision_shape_3d_interacted(interactor: Interactor) -> void:
	print("muere")
	pass # Replace with function body.


func _on_collision_shape_3d_child_entered_tree(node: Node) -> void:
	pass # Replace with function body.
