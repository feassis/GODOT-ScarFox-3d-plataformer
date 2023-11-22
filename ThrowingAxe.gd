extends RigidBody3D
class_name TAxe

@export_category("Setup")
@export var projectileSpeed: float

var isActive:bool = true
var damage: float = 0

var desiredTarget: DesiredTarget

func Setup(target: DesiredTarget, targetPosition: Vector3, startPos: Vector3, dmg: float, yOffset: float):
	desiredTarget = target
	damage = dmg
	var direction = (targetPosition + Vector3.UP * yOffset - startPos).normalized()
	linear_velocity = direction * projectileSpeed
	

enum DesiredTarget {Player, AI}


func _on_timer_timeout():
	queue_free()

func _physics_process(delta):
	if linear_velocity.length() < 0.5:
		isActive = false


func _on_body_entered(body):
	isActive = false



func _on_area_3d_body_entered(body):
	if desiredTarget == DesiredTarget.Player:
		if body is Player:
			if isActive:
				(body as Player).TakeDamage(damage)
				isActive = false
	
