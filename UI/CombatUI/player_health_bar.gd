extends Control
class_name PlayerHealthBar

@export_category("Objects")
@export var heathBar : TextureProgressBar = null

func _init():
	Globals.playerHealthBar = self

func Setup(maxHP: float, currentHP: float):
	heathBar.max_value = maxHP
	heathBar.value = currentHP
	
func UpdateHP(currentHP: float):
	heathBar.value = currentHP
