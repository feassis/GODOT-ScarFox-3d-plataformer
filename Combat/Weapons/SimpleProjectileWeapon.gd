extends Weapon

@export_category("Objects")
@export var projectileSpawnPosition: Node3D = null
@export var projectilePrefab: PackedScene = null

@export_category("Weapon Setup")
@export var jumpForce:float = 15
@export var dashForce:float = 15
@export var dashDuration: float = 0.3
@export var cameraOffset:Vector3 = Vector3.ZERO
@export var damage:float = 2


func CanShoot():
	return HasAmmo() and not IsOnCooldown()

func  TryAttack(cameraRay: RayCast3D):
	if IsOnCooldown():
		return
		
	if not HasAmmo():
		return
	
	Attack(cameraRay)

func Attack(cameraRay: RayCast3D):
	super(cameraRay)
	Globals.crosshair.PlayShootAnim()
	var projectile = SpawnProjectile()
	var collisionPoint: Vector3
	if cameraRay.is_colliding() && ((collisionPoint - cameraRay.global_transform.origin).length() > 10):
		collisionPoint = cameraRay.get_collision_point() + cameraOffset
	else:
		collisionPoint = cameraRay.global_position + (cameraRay.global_transform.basis.z).normalized() * -15 + cameraOffset
	projectileSpawnPosition.look_at_from_position(projectileSpawnPosition.global_position, collisionPoint, Vector3.UP, true)
	projectile.global_transform = projectileSpawnPosition.global_transform
		
	get_tree().get_root().add_child(projectile)
	ConsumeAmmo();

	
func ConsumeAmmo():
	ammo = clamp(ammo - 1, 0, magazineSize)
	(weaponUI as WeaponDisplayUI).ConsumeAmmo()
	
	if ammo <=0:
		hasToReload = true
		reloadingTimer = autoReloadTime

func SpawnProjectile() -> Node:
	var projectile = projectilePrefab.instantiate()
	(projectile as Projectile).damage = damage
	return projectile

func SpaceMovementSkill():
	var projectile = SpawnProjectile()
	projectileSpawnPosition.global_rotation_degrees = Vector3 (90, 0, 0)
	projectile.global_transform = projectileSpawnPosition.global_transform
		
	get_tree().get_root().add_child(projectile)
	(Globals.character as Player).velocity.y = jumpForce
	ConsumeAmmo()
	
func TrySpaceMovementSkill():
	if not HasAmmo():
		return
	
	SpaceMovementSkill()
	
func TryAttackMovementSkill():
	if not HasAmmo():
		return
	
	AttackMovementSkill()

func AttackMovementSkill():
	var projectile = SpawnProjectile()
	projectile.global_transform = projectileSpawnPosition.global_transform
		
	get_tree().get_root().add_child(projectile)
	(Globals.character as Player).ForceDash((Globals.character as Player).body.global_transform.basis.z.normalized() * dashForce, dashDuration) 
	ConsumeAmmo()
