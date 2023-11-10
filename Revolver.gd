extends OffHandWeapon

@export_category("Setup")
@export var dashVelocity: float = 20
@export var dashDuration: float = 0.5
@export var reloadDurationPerBullet: float = 1.5
@export var perfectReloadTime: float = 0.75
@export var perfectReloadLimitTime:float = 0.25

@export_category("Objects")
@export var projectileSpawnPosition: Node3D = null
@export var projectilePrefab: PackedScene = null

func TryToMovementAttack():
	if not HasAmmo() or IsOnCooldown():
		return
	
	MovementAttack()
	
func MovementAttack():
	pass

func GoToReloadingState():
	pass
	
func Reload():
	pass
