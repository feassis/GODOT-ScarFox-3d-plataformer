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

@export_category("Debug")
@export var debug: bool
@export var debugSphre : PackedScene

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
	print("is colliding: " + str(cameraRay.is_colliding()) + " distance: " + str(collisionPoint.distance_to(cameraRay.global_transform.origin)) )
	if cameraRay.is_colliding() && ((collisionPoint.distance_to(cameraRay.global_transform.origin)) > 2):
		collisionPoint = cameraRay.get_collision_point()
		print("Collided")
	else:
		collisionPoint = cameraRay.global_position + (cameraRay.global_transform.basis.z).normalized() * -15 + cameraOffset
		print("Did not collide")
		
	if debug:
		var instance = debugSphre.instantiate()
		instance.global_position = collisionPoint
		get_tree().get_root().add_child(instance)
	
	projectileSpawnPosition.look_at(collisionPoint)
	projectile.global_transform = projectileSpawnPosition.global_transform
	(projectile as Projectile).targetPosition = collisionPoint
		
	get_tree().get_root().add_child(projectile)
	ConsumeAmmo();

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
