extends CharacterBody3D
class_name Player

@export_category("Setup -> Movement -> Platform")
@export var normalSpeed: float = 5.0
@export var sprintSpeed: float = 9.0
@export var deacelerationOnAir: float = 1.0
@export var deacelerationOnFloor: float = 15.0
@export var onAirDamping: float = 0.3

@export_category("Setup -> Jump -> Platform")
@export var JUMP_VELOCITY: float = 4.5
@export var cayoteTimeDuration: float = 0.5
@export var gravityIncrease: float = 9.8
@export var jumpButtonGracePeriod: float = 0.5

@export_category("Setup -> Movement -> Platform")
@export var shooterNormalSpeed: float = 3.0
@export var shooterSprintSpeed: float = 5.0

@export_category("Camera")
@export var platformSpringArm: CharacterSpringArm = null
@export var shooterSpringArm: CharacterSpringArm = null
@export var transitionCamera: Camera3D = null
@export var cameraTransitionDuration: float = 0.5

@export_category("Objects")
@export var body: Body = null
@export var springArmOffset: Node3D = null

var _currentSpeed: float = normalSpeed
var onJumpStartSpeed: float = 0
var isOnCayoteTime: bool = false
var cayoteTimeExpired: bool = false
var cayoteTimer: float = 0
var jumpButtonIsPressed: bool = false
var jumpButtonGraceTimer = 0
var cameraIsTransitioning: bool

var cameraTween
var gameplayMode: GameState = GameState.PlatformMode
var jumped: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	
	if Input.is_action_just_pressed("aim"):
		CameraTransition(platformSpringArm, shooterSpringArm, cameraTransitionDuration)
	
	if Input.is_action_just_released("aim"):
		CameraTransition(shooterSpringArm, platformSpringArm,  cameraTransitionDuration)
	
	HandleFallingLogic(delta)
	
	SetMoveSpeed()

	# Handle Jump.
	if CanJump() and Input.is_action_just_pressed("jump"):
		Jump()
		
	if jumpButtonIsPressed:
		jumpButtonGraceTimer += delta
		if jumpButtonGraceTimer > jumpButtonGracePeriod:
			jumpButtonIsPressed = false
			jumpButtonGraceTimer = 0
	
	if Input.is_action_just_released("jump"):
		jumpButtonIsPressed = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	Move(direction, delta)

	move_and_slide()
	
	if is_on_floor():
		body.animate(velocity)
	else:
		body.PlayAnimation(Body.AnimEnumState.Falling)

func Move(direction: Vector3, delta: float) -> void:
	match gameplayMode:
		GameState.PlatformMode:
			MoveOnPlatformMode(direction, delta)
		
		GameState.ShooterMode:
			pass
			

func SetMoveSpeed() -> void:
	match gameplayMode:
		GameState.PlatformMode:
			if is_running():
				_currentSpeed = sprintSpeed
			else:
				_currentSpeed = normalSpeed
		
		GameState.ShooterMode:
			if is_running():
				_currentSpeed = shooterSprintSpeed
			else:
				_currentSpeed = shooterNormalSpeed

func MoveOnPlatformMode(direction: Vector3, delta: float):
	direction = direction.rotated(Vector3.UP, platformSpringArm.rotation.y)
	
	if not is_on_floor():
		_currentSpeed *= onAirDamping
	
	if direction:
		if is_on_floor():
			velocity.x = direction.x * _currentSpeed
			velocity.z = direction.z * _currentSpeed
		else:
			velocity.x = clamp(velocity.x +  direction.x * onJumpStartSpeed * onAirDamping* delta, -onJumpStartSpeed, onJumpStartSpeed)
			velocity.z = clamp(velocity.z +  direction.z * onJumpStartSpeed * onAirDamping* delta, -onJumpStartSpeed, onJumpStartSpeed)
		body.apply_rotation(velocity.normalized())
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0,deacelerationOnFloor * delta)
			velocity.z = move_toward(velocity.z, 0, deacelerationOnFloor * delta)

func is_running() -> bool:
	if Input.is_action_pressed("run"):
		return true	
		
	return false

func Jump() -> void:
	jumped = true
	velocity.y = JUMP_VELOCITY
	body.PlayAnimation(Body.AnimEnumState.Jump)
	onJumpStartSpeed = _currentSpeed
	
func HandleFallingLogic(delta) -> void:
	var gravityOnBody: float
	
	if jumpButtonIsPressed:
		gravityOnBody = gravity
	else: 
		gravityOnBody = gravity + gravityIncrease
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravityOnBody * delta
		if not isOnCayoteTime and not cayoteTimeExpired:
			isOnCayoteTime = true
		if isOnCayoteTime:
			cayoteTimer += delta
			if (cayoteTimer > cayoteTimeDuration):
				cayoteTimeExpired = true
				isOnCayoteTime = false
	elif is_on_floor() and (cayoteTimer > 0):
		cayoteTimer = 0
		cayoteTimeExpired = false
	
	if is_on_floor() and jumped:
		jumped = false

func CameraTransition(from: CharacterSpringArm, to: CharacterSpringArm, duration: float = 1):
	if cameraIsTransitioning:
		return
	
	cameraIsTransitioning = true
	
	transitionCamera.global_position = from.GetCamera().global_position
	transitionCamera.global_rotation = from.GetCamera().global_rotation
	
	transitionCamera.current = true
		
	cameraTween = create_tween()
	cameraTween.tween_property(transitionCamera, "global_position", to.GetCamera().global_position , duration)
	cameraTween.parallel().tween_property(transitionCamera, "global_rotation", to.GetCamera().global_rotation , duration)
	await cameraTween.finished
	SwitchCamera(transitionCamera, to.GetCamera())

func SwitchCamera(from: Camera3D, to: Camera3D):
	to.current = true
	cameraIsTransitioning = false

func CanJump() -> bool:
	return  (is_on_floor() or isOnCayoteTime) and not jumped

enum GameState {PlatformMode, ShooterMode}
