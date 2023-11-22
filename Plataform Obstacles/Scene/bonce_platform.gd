extends Node3D
class_name BouncePlatform

@export_category("Objects")
@export var animation: AnimationPlayer = null

@export_category("Setup")
@export var bounceForce: float
@export var carryMoment: bool
@export var carryPercentage: float = 0.8
@export var ySpeedTheshold: float = 2


var playerLandingVelocity: Vector3

func PlayerEnteredOnBounce(onEnterVelocity: Vector3, player:Player):
	print("Player Velocity On Collision: " + str(onEnterVelocity))

func _on_area_3d_body_entered(body):
	if body is Player:
		playerLandingVelocity = (body as Player).preMovementVelocity
		if abs(playerLandingVelocity.y) < ySpeedTheshold:
			return
		(body as Player).GoToBounceStart()
		animation.play("BounceDown")


func _on_animation_player_animation_finished(anim_name):
	match  anim_name:
		"BounceDown":
			animation.play("BounceUP")
			var carriedVelocity = playerLandingVelocity 
			carriedVelocity.y = carriedVelocity.y * (-1) * carryPercentage
			
			if not carryMoment:
				carriedVelocity.x = 0
				carriedVelocity.z = 0
			
			Globals.character.BounceJump(carriedVelocity, Vector3.UP * bounceForce)

