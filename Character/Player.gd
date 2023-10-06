extends CharacterBody3D
class_name Player

@export_category("Setup")
@export var normalSpeed: float = 5.0
@export var sprintSpeed: float = 9.0
@export var JUMP_VELOCITY: float = 4.5
@export var deacelerationOnAir: float = 1.0
@export var deacelerationOnFloor: float = 15.0
@export var onAirDamping: float = 0.3

var _currentSpeed: float = normalSpeed

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_category("Objects")
@export var body: Body = null
@export var springArmOffset: Node3D = null


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		body.PlayAnimation(Body.AnimEnumState.Jump)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	direction = direction.rotated(Vector3.UP, springArmOffset.rotation.y)
	
	if is_running():
		_currentSpeed = sprintSpeed
	else:
		_currentSpeed = normalSpeed
	
	if not is_on_floor():
		_currentSpeed *= onAirDamping
	
	if direction:
		
		velocity.x = direction.x * _currentSpeed
		velocity.z = direction.z * _currentSpeed
		body.apply_rotation(velocity.normalized())
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0,deacelerationOnFloor * delta)
			velocity.z = move_toward(velocity.z, 0, deacelerationOnFloor * delta)

	move_and_slide()
	
	if is_on_floor():
		body.animate(velocity)
	else:
		pass

func is_running() -> bool:
	if Input.is_action_pressed("run"):
		return true	
		
	return false