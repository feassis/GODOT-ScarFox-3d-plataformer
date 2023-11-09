extends CharacterBody3D
class_name Enemy

@export_category("Objects")
@export var health: Node3D = null
@export var body: Node3D

func OnDamageTaken():
	pass

func OnDeath():
	pass
	
func OnHeal():
	pass

func TakeDamage(dmg: float):
	(health as Health).TakeDamage(dmg)
