extends AnimatableBody3D
class_name LinearMovingPlatform

@export_category("Setup")
@export var speed: float = 1
@export var movementType: MovementType = MovementType.Ciclic

@export_category("Object")
@export var trail:Node3D = null

enum MovementType {Ciclic, FollowTrack}
var trailNodes: Array 
var nodeIndex: int = 0
var isGoingForward: bool = true

var velocity: Vector3

func _ready():
	trailNodes = trail.get_children()
	
	
func _physics_process(delta):
	var targetPos= (trailNodes[nodeIndex] as Node3D).position
	var direction =  (targetPos - position).normalized()
	
	if position.distance_squared_to(targetPos) < 0.01:
		SetNextNode()
	
	velocity =  direction *  speed
	global_position = global_position + velocity *  delta
	

func SetNextNode() -> void:
	match movementType:
		MovementType.Ciclic:
			nodeIndex += 1
			if nodeIndex >= trailNodes.size():
				nodeIndex = 0
				
		MovementType.FollowTrack:
			if isGoingForward:
				nodeIndex +=1
			else:
				nodeIndex -= 1
			
			if nodeIndex < 0:
				nodeIndex = 0
				isGoingForward = true
			elif nodeIndex >= trailNodes.size():
				nodeIndex = trailNodes.size() - 1
				isGoingForward = false
				

func GetVelocity() -> Vector3:
	return velocity

