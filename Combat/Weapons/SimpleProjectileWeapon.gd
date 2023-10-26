extends Weapon

@export_category("Objects")
@export var projectileSpawnPosition: Node3D = null
@export var projectilePrefab: PackedScene = null


func  TryAttack(cameraRay: RayCast3D):
	if IsOnCooldown():
		return
		
	Attack(cameraRay)

func Attack(cameraRay: RayCast3D):
	super(cameraRay)
	var projectile = projectilePrefab.instantiate()
	var collisionPoint: Vector3
	if cameraRay.is_colliding() && ((collisionPoint - cameraRay.global_transform.origin).length() > 10):
		collisionPoint = cameraRay.get_collision_point()
	else:
		collisionPoint = cameraRay.global_position + (cameraRay.global_transform.basis.z).normalized() * -15	
	projectileSpawnPosition.look_at_from_position(projectileSpawnPosition.global_position, collisionPoint, Vector3.UP, true)
	projectile.global_transform = projectileSpawnPosition.global_transform
		
	get_tree().get_root().add_child(projectile)
	Globals.crosshair.PlayShootAnim()
	
