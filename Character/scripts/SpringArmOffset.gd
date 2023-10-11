extends Node3D
class_name CharacterSpringArm

@export_category("Setup")
@export var mouseSensibility: float = 0.005
@export var cameraXRotationLowerBound: float = -PI/4
@export var cameraXRotationUpperBound: float = PI/12

@export_category("Objects")
@export var springArm: SpringArm3D = null

func  _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouseSensibility)
		springArm.rotate_x(-event.relative.y * mouseSensibility)
		springArm.rotation.x = clamp(springArm.rotation.x, cameraXRotationLowerBound, cameraXRotationUpperBound)
