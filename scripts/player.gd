extends CharacterBody3D

@onready var head = $Camera
@onready var use_ray = %RayCast3D
@onready var object_inspect = %inspect
@onready var joint = %inspect_joint
@onready var hud = %HUD

var throw_force = 0.3
var follow_speed = 20.0

var held_item = null

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
	_check_ray()
	_handle_item()




func _input(event):
	if event is InputEventMouseMotion:
		look_rotation.y -= sensitivity * event.relative.x
		look_rotation.x -= sensitivity * event.relative.y
		look_rotation.x = clamp(look_rotation.x, -80, 50)
		
	if Input.is_action_just_pressed("use"):
		if use_ray.is_colliding():
			if use_ray.get_collider().is_in_group("pick_up"):
				print(use_ray.get_collider().name)
				_pick_up_item(use_ray.get_collider())
	if Input.is_action_just_pressed("drop"):
		_throw_held_object()

func _pick_up_item(item):
	if held_item != null: return
	held_item = item
	joint.set_node_b(held_item.get_path())
	var grab_tween = create_tween()
	grab_tween.tween_property(held_item, "global_position", joint.global_position, 0.2)

func _throw_held_object():
	if held_item != null: return
	var obj:RigidBody3D = held_item
	held_item = null
	joint.set_node_b(joint.get_path())
	obj.apply_central_impulse(-head.global_basis.z * throw_force * 2.0)

func _handle_item():
	if held_item != null:
		var targetPos = joint.global_transform.origin # 2.5 units in front of camera
		var objectPos = held_item.global_transform.origin # Held object position
		held_item.linear_velocity = (targetPos - objectPos) * follow_speed


func _check_ray():
	if use_ray.is_colliding():
		if use_ray.get_collider().is_in_group("highlight"):
			hud.target_state(true)
		else:
			hud.target_state(false)
	else:
		hud.target_state(false)
