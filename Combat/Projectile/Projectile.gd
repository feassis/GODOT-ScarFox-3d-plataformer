extends Node3D
class_name Projectile

@export_category("Projectile Setup")
@export var projectileSpeed: float = 10
@export var projectileRange: float = 100

@export_category("Debug")
@export var debug: bool = false
@export var debugSphere: PackedScene = null
@export var debugSpawnTimer: float = 0.5

var debugtimer:float = 0

var startPosition: Vector3
var gotoDirection: Vector3
var damage: float

var targetPosition: Vector3;

func GetFowardVector() -> Vector3:
	return targetPosition - startPosition
	
func _ready():
	startPosition = global_position
	

	
func _physics_process(delta):
	if debug:
		if debugtimer <= 0:
			var instance = debugSphere.instantiate()
			instance.global_position = global_position
			debugtimer = debugSpawnTimer
			get_tree().get_root().add_child(instance)
			
		debugtimer -= delta
	global_position = global_position + GetFowardVector().normalized() * delta * projectileSpeed
	
	if global_position.distance_squared_to(startPosition) > projectileRange * projectileRange:
		Destruction()
		
func Destruction():
	remove_child(self)
	self.queue_free()


func _on_body_entered(body):
	if body is Enemy:
		(body as Enemy).TakeDamage(damage)
		Destruction()
