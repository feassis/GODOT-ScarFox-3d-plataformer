extends Control
class_name WeaponDisplayUI

@export_category("ObjectRefs")
@export var ammoContainter: HBoxContainer = null
@export var realodingProgresseBar: ProgressBar = null
@export var reloadingLabel: Label = null
@export var cooldownBar: TextureProgressBar = null
@export var weaponIcon: TextureRect = null

@export_category("Prefabs")
@export var ammoPrefab: PackedScene

var ammoArray: Array

var myWeapon : Weapon

func _process(delta):
	realodingProgresseBar.value = myWeapon.reloadingTimer
	cooldownBar.value = myWeapon.cooldown
	
	if realodingProgresseBar.value > 0:
		reloadingLabel.show()
	else:
		reloadingLabel.hide()

func Setup(weapon: Weapon):
	myWeapon = weapon
	weaponIcon.texture = myWeapon.weaponIcon
	
	InstantiateAllAmmo()
	realodingProgresseBar.max_value = myWeapon.autoReloadTime
	cooldownBar.max_value = myWeapon.GetWeaponCooldown()

func InstantiateAllAmmo():
	for i in range(0, myWeapon.magazineSize):
		var ammoInstance = ammoPrefab.instantiate()
		ammoInstance.texture = myWeapon.ammoIcon
		ammoContainter.add_child(ammoInstance)
		ammoArray.append(ammoInstance)

func ConsumeAmmo(ammoConsumed: int = 1):
	for i in range(0, ammoConsumed):
		var instance = ammoArray.pop_back()
		instance.queue_free()
	
	
