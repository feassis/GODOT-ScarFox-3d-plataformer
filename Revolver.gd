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

func TryToMovementAttack(inputDirection: Vector3):
	if not HasAmmo() or IsOnCooldown():
		return
	
	MovementAttack(inputDirection)
	
func MovementAttack(inputDirection: Vector3):
	var goingz: bool = abs(inputDirection.x) < abs(inputDirection.z)
	
	if goingz:
		(Globals.character as Player).ForceDash( Vector3(0,0,inputDirection.z).normalized()*dashVelocity, dashDuration)
	else: 
		(Globals.character as Player).ForceDash( Vector3(inputDirection.x,0,0).normalized()*dashVelocity, dashDuration)

func GoToReloadingState():
	pass
	
func Reload():
	pass
