extends Control
class_name GUI;


@export_category("Object")
@export var shooterExclusiveUI: Control
@export var platformExclusiveUI: Control
@export var weaponContainerHolder: Control

@export_category("Prefabs")
@export var weaponDisplayPrefab: PackedScene = null

func _init():
	Globals.gui = self

func OnGameModeChange(gamemode : Player.GameState):
	match gamemode:
		Player.GameState.PlatformMode:
			shooterExclusiveUI.hide()
			platformExclusiveUI.show()
		
		Player.GameState.ShooterMode:
			shooterExclusiveUI.show()
			platformExclusiveUI.hide()

func InstantiateWeaponDisplay(weapon: Weapon) -> WeaponDisplayUI:
	var weaponDisplayInstance = weaponDisplayPrefab.instantiate()
	(weaponDisplayInstance as WeaponDisplayUI).Setup(weapon)
	weaponContainerHolder.add_child(weaponDisplayInstance)
	return weaponDisplayInstance
