extends CharacterBody3D
class_name Player

@export_category("Setup -> Movement -> Platform")
@export var normalSpeed: float = 5.0
@export var walkSpeed: float = 9.0
@export var deacelerationOnAir: float = 1.0
@export var deacelerationOnFloor: float = 15.0
@export var onAirDamping: float = 0.3

@export_category("Setup -> Jump -> Platform")
@export var JUMP_VELOCITY: float = 4.5
@export var cayoteTimeDuration: float = 0.5
@export var gravityIncrease: float = 9.8
@export var jumpButtonGracePeriod: float = 0.5
@export var maxFallVelocity: float = 20

@export_category("Setup -> Movement -> Shooter")
@export var shooterNormalSpeed: float = 3.0
@export var shooterSprintSpeed: float = 5.0
@export var dashVelocity: float = 20
@export var dashDuration: float = 0.5

@export_category("Setup -> Movement -> Reloading")
@export var reloadingNormalSpeed: float = 1.0

@export_category("Combat")
@export var health: Node3D

@export_category("Camera")
@export var platformSpringArm: CharacterSpringArm = null
@export var shooterSpringArm: CharacterSpringArm = null
@export var transitionCamera: Camera3D = null
@export var cameraTransitionDuration: float = 0.5

@export_category("Objects")
@export var activeWeapon: Node3D = null
@export var offhandWeapon: Node3D = null
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
var spawnPosition

var cameraTween
var gameplayMode: GameState = GameState.PlatformMode
var jumped: bool = false
var gameStateRequestedLast:GameState = GameState.PlatformMode

var isDashing: bool = false
var dashingTimer:float = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spawnPosition = global_position
	Globals.character = self
	(health as Health).parent = self
	(Globals.playerHealthBar as PlayerHealthBar).Setup((health as Health).MaxHP, (health as Health).currentHP)

func _physics_process(delta):
	
	HandleGameModeState()
	
	HandleFallingLogic(delta)
	
	SetMoveSpeed()

	HandleJumpLogic(delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	HandleDashLogic(delta, direction)
	
	Move(direction, delta)
	
	HandleAttackLogic()
	HandleReloadLogic()

	move_and_slide()
	
	if is_on_floor():
		if gameplayMode == GameState.PlatformMode:
			body.animate(velocity, gameplayMode)
		elif gameplayMode == GameState.ShooterMode:
			body.animate(direction, gameplayMode)
		elif  gameplayMode == GameState.ReloadingMode:
			body.animate(velocity, gameplayMode)
	else:
		body.PlayFallAnim()

func HandleReloadLogic():
	if Input.is_action_just_pressed("reload"):
		(offhandWeapon as OffHandWeapon).GoToReloadingState()

func Move(direction: Vector3, delta: float) -> void:
	if isDashing:
		return
	
	direction = direction.rotated(Vector3.UP, platformSpringArm.rotation.y)
	
	match gameplayMode:
		GameState.PlatformMode:
			MoveOnPlatformMode(direction, delta)
		
		GameState.ShooterMode:
			MoveOnShooterMode(direction, delta)
		
		GameState.ReloadingMode:
			MoveOnReloadingMode(direction, delta)
			
func HandleDashLogic(delta:float, direction: Vector3):
	if isDashing:
		dashingTimer -= delta
		
		if dashingTimer <= 0:
			isDashing = false
			dashingTimer = 0
			if gameplayMode == GameState.ShooterMode:
				velocity = Vector3.ZERO

	if gameplayMode == GameState.PlatformMode:
		return
	
	if direction == Vector3.ZERO:
		direction = Vector3(0,0,1)
	
	direction = direction.rotated(Vector3.UP, shooterSpringArm.rotation.y)
	
	if CanDash() and Input.is_action_just_pressed("dodge") and is_on_floor():
		(offhandWeapon as OffHandWeapon).TryToMovementAttack(direction)

func ForceDash(dashForce: Vector3, dashTime: float):
	isDashing = true
	dashingTimer = dashTime
	velocity = dashForce

func HandleGameModeState():
	
	if Input.is_action_just_pressed("aim"):
		gameStateRequestedLast = GameState.ShooterMode
	
	if Input.is_action_just_released("aim"):
		gameStateRequestedLast = GameState.PlatformMode
	
	if CanChangeState() and gameStateRequestedLast != gameplayMode:
		ChangeGameplayState(gameStateRequestedLast)

func CanDash() -> bool:
	return not isDashing

func HandleAttackLogic():
	if Input.is_action_just_pressed("shoot"):
			Shoot()
	
func Shoot():
	if gameplayMode == GameState.ShooterMode:
		if activeWeapon.CanShoot():
			body.Shoot()
		
	if gameplayMode == GameState.PlatformMode:
		(activeWeapon as Weapon).TryAttackMovementSkill()
	
func Attack():
	(activeWeapon as Weapon).TryAttack(shooterSpringArm.ray)

func HandleJumpLogic(delta:float):
	if gameplayMode == GameState.ShooterMode:
		return 
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if CanJump():
			jumpButtonIsPressed = true
			Jump()
		else:
			(activeWeapon as Weapon).TrySpaceMovementSkill()
		
	if jumpButtonIsPressed:
		jumpButtonGraceTimer += delta
		if jumpButtonGraceTimer > jumpButtonGracePeriod:
			jumpButtonIsPressed = false
			jumpButtonGraceTimer = 0
	
	if Input.is_action_just_released("jump"):
		jumpButtonIsPressed = false

func SetMoveSpeed() -> void:
	match gameplayMode:
		GameState.PlatformMode:
			if is_walking():
				_currentSpeed = walkSpeed
			else:
				_currentSpeed = normalSpeed
		
		GameState.ShooterMode:
			if is_walking():
				_currentSpeed = shooterSprintSpeed
			else:
				_currentSpeed = shooterNormalSpeed
		GameState.ReloadingMode:
			_currentSpeed = reloadingNormalSpeed
		

func ChangeGameplayState(desiredState: GameState):
	gameplayMode = desiredState
	get_tree().call_group("OnGamemodeChange", "OnGameModeChange", gameplayMode)
	
	match desiredState:
		GameState.PlatformMode:
			CameraTransition(shooterSpringArm, platformSpringArm,  cameraTransitionDuration)
		
		GameState.ShooterMode:
			CameraTransition(platformSpringArm, shooterSpringArm, cameraTransitionDuration)
			
func CanChangeState() -> bool:
	return not cameraIsTransitioning and not isDashing and not gameplayMode == GameState.ReloadingMode

func MoveOnShooterMode(direction: Vector3, delta: float):
	if direction:
		if is_on_floor():
			velocity.x = direction.x * _currentSpeed
			velocity.z = direction.z * _currentSpeed
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, deacelerationOnFloor * delta)
			velocity.z = move_toward(velocity.z, 0, deacelerationOnFloor * delta)
	body. apply_rotation_custom_velocity(-shooterSpringArm.camera.get_camera_transform().basis.z.normalized(), 1)

func MoveOnPlatformMode(direction: Vector3, delta: float):
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
			
func MoveOnReloadingMode(direction: Vector3, delta: float):
	if direction:
		if is_on_floor():
			velocity.x = direction.x * _currentSpeed
			velocity.z = direction.z * _currentSpeed
		body.apply_rotation(velocity.normalized())
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0,deacelerationOnFloor * delta)
			velocity.z = move_toward(velocity.z, 0, deacelerationOnFloor * delta)

func is_walking() -> bool:
	if Input.is_action_pressed("walk"):
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
		velocity.y = clamp(velocity.y - gravityOnBody * delta, -maxFallVelocity, 2 * maxFallVelocity) 
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

func GoToSpawnPosition():
	global_position = spawnPosition

func TakeDamage(dmg:float):
	(health as Health).TakeDamage(dmg)

func OnDamageTaken():
	(Globals.playerHealthBar as PlayerHealthBar).UpdateHP((health as Health).currentHP)

func OnDeath():
	pass
	
func OnHeal():
	(Globals.playerHealthBar as PlayerHealthBar).UpdateHP((health as Health).currentHP)

enum GameState {PlatformMode, ShooterMode, ReloadingMode}
