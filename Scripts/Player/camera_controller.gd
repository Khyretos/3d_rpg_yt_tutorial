extends Node3D

var camroot_h = 0
var camroot_v = 0

@export var cam_v_max = 75
@export var cam_v_min = -55

var h_sensititvity: float = 0.01
var v_sensititvity: float = 0.01
var h_acceleration: float = 10
var v_acceleration: float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# capture mouse movement (also hides mouse)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# this function will specifically look for inputs
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camroot_h += -event.relative.x * h_sensititvity
		camroot_v += event.relative.y * v_sensititvity

# P
func _physics_process(delta: float) -> void:
	# limit the vertical rotation between the limits set
	camroot_v = clamp(camroot_v, deg_to_rad(cam_v_min), deg_to_rad(cam_v_max))
	get_node("CameraPosition").rotation.y = lerpf(get_node("CameraPosition").rotation.y, camroot_h, delta * h_acceleration)
	get_node("CameraPosition/SpringArm").rotation.x = lerpf(get_node("CameraPosition/SpringArm").rotation.x, camroot_v, delta * v_acceleration)
