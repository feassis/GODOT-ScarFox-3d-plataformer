extends Node3D
class_name  Weapon

@export_category("Weapon Setup")
@export_range(0.01, 100) var fireRate: float = 1

@export_category("WeaponUISetup")
@export var weaponIcon : CompressedTexture2D = null
@export var ammoIcon : CompressedTexture2D = null
@export var magazineSize = 1
@export var autoReloadTime = 1

var weaponUI: WeaponDisplayUI 
var reloadingTimer = 0
var ammo
var hasToReload: bool = false
var cooldown: float = 0


func CanShoot():
	return not IsOnCooldown()

func IsOnCooldown() -> bool:
	return cooldown > 0

func GetWeaponCooldown() -> float:
	return 1/fireRate
	
func  _ready():
	weaponUI = (Globals.gui as GUI).InstantiateWeaponDisplay(self)
	ammo = magazineSize
	
func HasAmmo() -> bool:
	return ammo > 0

func _process(delta):
	if cooldown > 0:
		cooldown = clamp(cooldown - delta, 0, 100)
		
	if hasToReload and (Globals.character as Player).is_on_floor():
		reloadingTimer -= delta
		
		if reloadingTimer <= 0:
			weaponUI.InstantiateAllAmmo()
			ammo = magazineSize
			hasToReload = false

func TryAttack(cameraRay: RayCast3D):
	pass

func Attack(cameraRay: RayCast3D):
	cooldown = GetWeaponCooldown()
	
func SpaceMovementSkill():
	pass
	
func TrySpaceMovementSkill():
	pass
	
func TryAttackMovementSkill():
	pass

func AttackMovementSkill():
	pass
