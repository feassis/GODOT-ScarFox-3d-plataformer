extends Control
class_name GUI;


@export_category("Object")
@export var shooterExclusiveUI: Control
@export var platformExclusiveUI: Control
@export var weaponContainerHolder: Control

@export_category("Prefabs")
@export var weaponDisplayPrefab: PackedScene = null
@export var revolverDisplayPrefab: PackedScene = null

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

func InstantiateWeaponDisplay(weapon: Weapon, type: WeaponUIType = WeaponUIType.Regular) -> WeaponDisplayUI:
	var weaponDisplayInstance = GetWeaponUI(type).instantiate()
	(weaponDisplayInstance as WeaponDisplayUI).Setup(weapon)
	weaponContainerHolder.add_child(weaponDisplayInstance)
	return weaponDisplayInstance

func GetWeaponUI(type: WeaponUIType) -> PackedScene:
	match type:
		WeaponUIType.Regular:
			return weaponDisplayPrefab
		WeaponUIType.Revolver:
			return revolverDisplayPrefab
		
	return null

enum WeaponUIType {Regular, Revolver}
