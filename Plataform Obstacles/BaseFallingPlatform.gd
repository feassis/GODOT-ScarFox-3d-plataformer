extends Node3D
class_name BaseFallingPlatform

@export_category("Objects")
@export var platform: RigidBody3D
@export var respawn: bool
@export var respawnTime: float = 10
@export var breakingTime: float = 4
@export var animation: AnimationPlayer = null

var startPosition: Vector3
var respawnTimer: float = 0
var respawnTimerOn : bool = false
var playerEnteredPlatform: bool = false
var dropTimer: float = 0

func _ready():
	startPosition = platform.global_position
	
func DropPlatform():
	animation.play("idle")
	platform.gravity_scale = 1
	playerEnteredPlatform = false
	
	if respawn:
		respawnTimerOn = true

func _process(delta):
	if respawnTimerOn:
		respawnTimer += delta
		
	if playerEnteredPlatform:
		dropTimer += delta
		
	if dropTimer >= breakingTime:
		DropPlatform()
		dropTimer = 0
		
	if respawnTimer >= respawnTime:
		respawnTimerOn = false
		RespawnPlatform()
		
func RespawnPlatform():
	platform.gravity_scale = 0
	platform.global_position = startPosition
	respawnTimer = 0
	respawnTimerOn = false
	playerEnteredPlatform = false
	
	

func _on_area_3d_body_entered(body):
	if body is Player:
		playerEnteredPlatform = true
		animation.play("breaking")
