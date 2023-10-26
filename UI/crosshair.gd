extends Control
class_name Crosshair

@export_category("Objects")
@export var animation: AnimationPlayer = null

func _ready():
	Globals.crosshair = self

func PlayShootAnim():
	animation.stop()
	animation.play("shoot")
