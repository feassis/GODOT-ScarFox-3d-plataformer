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

func animate(velocity: Vector3) -> void:
	if velocity:
		if character.is_running():
			PlayAnimation(AnimEnumState.Run)
			return
		PlayAnimation(AnimEnumState.Walk)
		return
	PlayAnimation(AnimEnumState.Idle)


enum AnimEnumState {Idle,Jump,Walk,Run, Falling}
