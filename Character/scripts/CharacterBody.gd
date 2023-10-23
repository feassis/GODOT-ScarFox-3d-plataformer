extends Node3D
class_name Body

@export_category("Setup")
@export var rotationVelocity: float = 0.15

@export_category("Objects")
@export var character: Player= null
@export var animation: AnimationPlayer = null

func apply_rotation(velocity: Vector3) -> void:
	var angularVelocity:float = atan2( velocity.x, velocity.z)
	rotation.y = lerp_angle(
		rotation.y,  angularVelocity, rotationVelocity
	)
	
func apply_rotation_custom_velocity(velocity: Vector3, customVelocity:float) -> void:
	var angularVelocity:float = atan2( velocity.x, velocity.z)
	rotation.y = lerp_angle(
		rotation.y,  angularVelocity, customVelocity
	)

func PlayAnimation(state : AnimEnumState) -> void:
	match state:
		AnimEnumState.Idle:
			animation.play("Idle")
		
		AnimEnumState.Run:
			animation.play("Running_A")
		
		AnimEnumState.Walk:
			animation.play("Walking_A")
		
		AnimEnumState.Jump:
			animation.play("Jump_Start")
			await animation.animation_finished
			animation.play("Jump_Idle")
		
		AnimEnumState.Falling:
			if animation.current_animation != "Jump_Start" || animation.current_animation != "Jump_Idle":
				animation.play("Jump_Idle")
		
		AnimEnumState.StrafeRight:
			animation.play("Running_Strafe_Right")
			
		AnimEnumState.StrafeLeft:
			animation.play("Running_Strafe_Left")
		
		AnimEnumState.WalkingBackwards:
			animation.play("Walking_Backwards")
		
		AnimEnumState.Aim:
			animation.play("1H_Ranged_Aiming")
		
		AnimEnumState.DodgeFoward:
			animation.play("Dodge_Forward")
		
		AnimEnumState.DodgeBackward:
			animation.play("Dodge_Backward")
			
		AnimEnumState.DodgeLeft:
			animation.play("Dodge_Left")
		
		AnimEnumState.DodgeRight:
			animation.play("Dodge_Right")

func animate(velocity: Vector3, gameMode: Player.GameState) -> void:
	match gameMode:
		Player.GameState.PlatformMode:
			PlatformWalk(velocity)
		Player.GameState.ShooterMode:
			ShooterWalk(velocity)
	
func ShooterWalk(velocity: Vector3):
	
	var goingz: bool = abs(velocity.x) < abs(velocity.z)
		
	if character.isDashing:
		if goingz:
			if velocity.z > 0:
				PlayAnimation(AnimEnumState.DodgeFoward)
			else:
				PlayAnimation(AnimEnumState.DodgeBackward)
		else:
			if velocity.x >= 0:
				PlayAnimation(AnimEnumState.DodgeRight)
			else:
				PlayAnimation(AnimEnumState.DodgeLeft)
		
		return
	
	if velocity:		
		if goingz:
			if velocity.z >= 0:
				if character.is_walking():
					PlayAnimation(AnimEnumState.Walk)
				else:
					PlayAnimation(AnimEnumState.Run)
			else:
				PlayAnimation(AnimEnumState.WalkingBackwards)
		else:
			if velocity.x >= 0:
				PlayAnimation(AnimEnumState.StrafeRight)
			else:
				PlayAnimation(AnimEnumState.StrafeLeft)
		return
	PlayAnimation(AnimEnumState.Aim)
	
	PlayAnimation(AnimEnumState.Idle)
	
func PlatformWalk(velocity: Vector3):
	if velocity:
		if character.is_walking():
			PlayAnimation(AnimEnumState.Walk)
			return
		PlayAnimation(AnimEnumState.Run)
		
		return
	PlayAnimation(AnimEnumState.Idle)


enum AnimEnumState {Idle,Jump,Walk,Run, Falling, StrafeLeft, StrafeRight, WalkingBackwards, Aim, DodgeFoward, DodgeBackward, DodgeLeft, DodgeRight }
