extends Enemy
class_name ShootingEnemy

@export_category("Setup")
@export var rotationVelocity: float = 30
@export var attackSpeed: float = 1
@export var facingAngle: float = 30
@export var dmg: float = 1
@export var yOffset: float = 1

@export_category("Objects")
@export var axeSpawnPosition:Node3D = null
@export var animator: AnimationPlayer = null
@export var axeOnHand: Node3D = null
@export var healthBar: TextureProgressBar = null

@export_category("Prefabs")
@export var throwingAxe: PackedScene

var target: Player
var cooldown:float = 0
var shootPos: Vector3

func _ready():
	(health as Health).parent = self
	healthBar.max_value = (health as Health).MaxHP
	healthBar.value = (health as Health).currentHP
	
func OnDamageTaken():
	healthBar.value = (health as Health).currentHP

func OnDeath():
	queue_free()
	
func OnHeal():
	healthBar.value = (health as Health).currentHP

func _process(delta):
	HandleRotation(delta)
	
	HandleAttackLogic(delta)
	
func HandleAttackLogic(delta: float):
	
	if(cooldown > 0):
		cooldown = clamp(cooldown - delta, 0, GetCooldown())
		return
	axeOnHand.show()
	
	if target == null:
		return
	
	if not IsFacingTarget():
		return
	
	shootPos = target.global_position
	animator.play("Throw")
	
	
func ThrowAxe():
	var axeInstance = throwingAxe.instantiate()
	axeOnHand.hide()
	axeInstance.global_transform = axeSpawnPosition.global_transform
	(axeInstance as TAxe).Setup(TAxe.DesiredTarget.Player, shootPos, axeSpawnPosition.global_position, dmg, yOffset)
	get_tree().get_root().add_child(axeInstance)
	cooldown = GetCooldown()

func IsFacingTarget() -> bool:
	var targetV = (target.global_position - global_position).normalized()
	var towardVector = body.global_transform.basis.z.normalized()
	var dotProduct = targetV.dot(towardVector)
	var angle = rad_to_deg(acos(dotProduct)) 
	
	return abs(angle) <= facingAngle
	
	
func HandleRotation(delta:float):
	if target != null:
		RotateTowardsTarget(delta)

func RotateTowardsTarget(delta: float):
	var target_rotation = atan2(target.position.x - global_position.x,target.position.z - global_position.z)
	body.rotation.y = lerp_angle(body.rotation.y, target_rotation, rotationVelocity * delta)
	#look_at(target.global_position, Vector3.UP, true)
	
	
func RotateToVelocity(delta: float):
	var angularVelocity:float = atan2( velocity.x, velocity.z)
	rotation.y = lerp_angle(
		rotation.y,  angularVelocity, rotationVelocity * delta
	)

func GetCooldown() -> float:
	return 1 / attackSpeed

func _on_detection_body_entered(body):
	if(body is Player):
		target = body


func _on_detection_body_exited(body):
	if(body is Player):
		target = null
