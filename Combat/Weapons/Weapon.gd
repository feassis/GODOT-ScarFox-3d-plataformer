extends Node3D
class_name  Weapon

@export_category("Weapon Setup")
@export_range(0.01, 100) var fireRate: float = 1

var cooldown: float = 0

func IsOnCooldown() -> bool:
	return cooldown > 0

func GetWeaponCooldown() -> float:
	return 1/fireRate

func _process(delta):
	if cooldown > 0:
		cooldown = clamp(cooldown - delta, 0, 100)

func TryAttack(cameraRay: RayCast3D):
	pass

func Attack(cameraRay: RayCast3D):
	cooldown = GetWeaponCooldown()
