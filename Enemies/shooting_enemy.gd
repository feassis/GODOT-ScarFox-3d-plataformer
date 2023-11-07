extends CharacterBody3D
class_name ShootingEnemy

@export_category("Setup")
@export var rotationVelocity: float = 30

@export_category("Objects")
@export var health: Node3D = null
@export var body: Node3D

var target: Player

func _ready():
	(health as Health).parent = self
	
func OnDamageTaken():
	pass

func OnDeath():
	pass
	
func OnHeal():
	pass

func _process(delta):
	HandleRotation(delta)
	
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

func _on_detection_body_entered(body):
	if(body is Player):
		target = body


func _on_detection_body_exited(body):
	if(body is Player):
		target = null
