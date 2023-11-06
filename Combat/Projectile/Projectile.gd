extends Node3D
class_name Projectile

@export_category("Projectile Setup")
@export var projectileSpeed: float = 10
@export var projectileRange: float = 100

var startPosition: Vector3
var gotoDirection: Vector3

func GetFowardVector() -> Vector3:
	return global_transform.basis.z
	
func _ready():
	startPosition = global_position
	

	
func _physics_process(delta):
	global_position = global_position + GetFowardVector().normalized() * delta * projectileSpeed
	
	if global_position.distance_squared_to(startPosition) > projectileRange * projectileRange:
		Destruction()
		
func Destruction():
	remove_child(self)
	self.queue_free()
