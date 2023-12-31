extends OffHandWeapon
class_name Revolver

@export_category("Setup")
@export var dashVelocity: float = 20
@export var dashDuration: float = 0.5
@export var reloadDurationPerBullet: float = 1.5
@export var perfectReloadTime: float = 0.75
@export var perfectReloadLimitTime:float = 0.25
@export var damage = 1

@export_category("Objects")
@export var projectileSpawnPosition: Node3D = null
@export var projectilePrefab: PackedScene = null

var weaponState: RevolverState = RevolverState.StandardUse
var timerPerBulletReload: float = 0
var playerStateBeforeReload: Player.GameState;

enum RevolverState {StandardUse, ManualReload}

func _ready():
	weaponUI = (Globals.gui as GUI).InstantiateWeaponDisplay(self, GUI.WeaponUIType.Revolver)
	ammo = magazineSize

func _process(delta):
	if weaponState == RevolverState.ManualReload:
		ManualReloadProcess(delta)
		return
	
	super(delta)

func ManualReloadProcess(delta: float):
	timerPerBulletReload += delta
	
	if Input.is_action_just_pressed("reload"):
		if timerPerBulletReload >= perfectReloadTime - perfectReloadLimitTime and timerPerBulletReload <= perfectReloadTime + perfectReloadLimitTime:
			Reload()
		else:
			timerPerBulletReload = 0
			(weaponUI as RevolverUI).OnReloadFail()
		return
		
	
	if timerPerBulletReload > reloadDurationPerBullet:
		Reload()

func TryToMovementAttack(inputDirection: Vector3):
	if not HasAmmo() or IsOnCooldown():
		return
	
	MovementAttack(inputDirection)
	
func MovementAttack(inputDirection: Vector3):
	var goingz: bool = abs(inputDirection.x) < abs(inputDirection.z)
	
	var direction = -inputDirection.normalized()

	(Globals.character as Player).ForceDash(-direction * dashVelocity, dashDuration)
		
	var projectileInstance = SpawnProjectile()
	projectileInstance.global_transform = projectileSpawnPosition.global_transform
	get_tree().get_root().add_child(projectileInstance)
	ConsumeAmmo()
	

func GoToReloadingState():
	weaponState = RevolverState.ManualReload
	playerStateBeforeReload = (Globals.character as Player).gameplayMode
	(Globals.character as Player).ChangeGameplayState(Player.GameState.ReloadingMode)
	
	
func Reload():
	ammo = clamp(ammo + 1, 0, magazineSize)
	timerPerBulletReload = 0
	(weaponUI as RevolverUI).OnReload()
	
	if ammo >= magazineSize:
		weaponState = RevolverState.StandardUse
		hasToReload = false
		(Globals.character as Player).ChangeGameplayState((Player.GameState.PlatformMode))

func GetBulletAmountToReload() -> int:
	return magazineSize - ammo

func SpawnProjectile() -> Node:
	var projectile = projectilePrefab.instantiate()
	(projectile as Projectile).damage = damage
	return projectile
