extends CharacterBody3D

@onready var head = $Camera
var look_rotation: Vector3 = Vector3.ZERO
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var sensitivity = 0.2



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)




func _physics_process(delta: float) -> void:
	head.rotation_degrees.x = look_rotation.x
	rotation_degrees.y = look_rotation.y

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()





func _input(event):
	if event is InputEventMouseMotion:
		look_rotation.y -= sensitivity * event.relative.x
		look_rotation.x -= sensitivity * event.relative.y
		look_rotation.x = clamp(look_rotation.x, -80, 50)
