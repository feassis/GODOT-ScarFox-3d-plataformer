extends Node3D
class_name Health

@export_category("Setup")
@export var MaxHP: float = 10

var currentHP:float
var parent

func _init():
	currentHP = MaxHP
	
func TakeDamage(dmg:float):
	currentHP = clamp(currentHP - dmg, 0, MaxHP)
	parent.OnDamageTaken()
	
	if(currentHP <= 0):
		parent.OnDeath()

func Heal(amount:float):
	currentHP = clamp(currentHP - amount, 0, MaxHP)
	parent.OnHeal()
