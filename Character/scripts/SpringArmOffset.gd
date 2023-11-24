extends Node3D
class_name CharacterSpringArm

@export_category("Setup")
@export var mouseSensibility: float = 0.005
@export var cameraXRotationLowerBound: float = -PI/3
@export var cameraXRotationUpperBound: float = PI/10
@export var debugOn:bool = false 

@export_category("Objects")
@export var springArm: SpringArm3D = null
@export var camera: Camera3D = null
@export var ray: RayCast3D = null
@export var debugSphere: Node3D = null
@export var debugSphereGreen: Node3D = null

func  _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouseSensibility)
		springArm.rotate_x(-event.relative.y * mouseSensibility)
		springArm.rotation.x = clamp(springArm.rotation.x, cameraXRotationLowerBound, cameraXRotationUpperBound)
		

func GetCamera() -> Camera3D:
	return camera
	
func GetSpringArm() -> SpringArm3D:
	return springArm

func _ready():
	if debugOn:
		debugSphere.show()
		debugSphereGreen.show()
	else: 
		debugSphere.hide()
		debugSphereGreen.hide()

func _process(delta):
	if not debugOn:
		return
	
	if ray.is_colliding():
		debugSphere.hide()
		debugSphereGreen.show()
		debugSphereGreen.global_position = ray.get_collision_point()
	else:
		debugSphere.show()
		debugSphereGreen.hide()
		debugSphere.global_position = ray.global_position + (ray.global_transform.basis.z).normalized() * -15
