extends Node3D
class_name Body

@export_category("Setup")
@export var rotationVelocity: float = 0.15

@export_category("Objects")
@export var character: CharacterBody3D = null
@export var animation: AnimationPlayer = null

func apply_rotation(velocity: Vector3) -> void:
	var angularVelocity:float = atan2( velocity.x, velocity.z)
	rotation.y = lerp_angle(
		rotation.y,  angularVelocity, rotationVelocity
	)


func animate(velocity: Vector3) -> void:
	if velocity:
		if character.is_running():
			animation.play("Running_A")
			return
		animation.play("Walking_A")
		return
	animation.play("Idle")
