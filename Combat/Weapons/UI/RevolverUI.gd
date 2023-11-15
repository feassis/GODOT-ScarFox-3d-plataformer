extends WeaponDisplayUI
class_name RevolverUI

@export_category("Prefabs")
@export var reloadingBulletUIPrefab: PackedScene = null

@export_category("Object")
@export var activeReloadContainer: HBoxContainer

var reloadBulletUIs: Array = []


func _process(delta):
	if (myWeapon as Revolver).weaponState == Revolver.RevolverState.ManualReload:
		activeReloadContainer.show()
		
		var bulletsToReload = (myWeapon as Revolver).GetBulletAmountToReload()
		
		if bulletsToReload  <= 0:
			return 
		
		if bulletsToReload  - reloadBulletUIs.size() >= 0:
			for i in bulletsToReload - reloadBulletUIs.size():
				InstantiateReloadBulletUI()
		
		(reloadBulletUIs[0] as ReloadBulletUI).UpdateArrowPosition((myWeapon as Revolver).timerPerBulletReload / (myWeapon as Revolver).reloadDurationPerBullet)
		return 
	
	activeReloadContainer.hide()
	super(delta)

func InstantiateReloadBulletUI():
	var instance = reloadingBulletUIPrefab.instantiate()
	activeReloadContainer.add_child(instance)
	reloadBulletUIs.push_back(instance)
	var percerntil: float = (myWeapon as Revolver).perfectReloadTime / (myWeapon as Revolver).reloadDurationPerBullet
	var size = (myWeapon as Revolver).perfectReloadLimitTime / (myWeapon as Revolver).reloadDurationPerBullet
	reloadBulletUIs[reloadBulletUIs.size()-1].Setup(percerntil, size)

func ClearReloadBulletUIs():
	for ui in reloadBulletUIs:
		ui.queue_free()
		
	reloadBulletUIs.clear()

func RemoveTopBulletUI():
	var bulletUI = reloadBulletUIs.pop_at(0)
	
	if bulletUI == null:
		return
	
	(bulletUI as ReloadBulletUI).queue_free()
	InstantiateAmmo()

func OnReload():
	RemoveTopBulletUI()
	
func InstantiateAmmo():
	var ammoInstance = ammoPrefab.instantiate()
	ammoInstance.texture = myWeapon.ammoIcon
	ammoContainter.add_child(ammoInstance)
	ammoArray.append(ammoInstance)
