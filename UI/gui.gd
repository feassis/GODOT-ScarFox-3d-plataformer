extends Control

@export_category("Object")
@export var shooterExclusiveUI: Control
@export var platformExclusiveUI: Control

func OnGameModeChange(gamemode : Player.GameState):
	match gamemode:
		Player.GameState.PlatformMode:
			shooterExclusiveUI.hide()
			platformExclusiveUI.show()
		
		Player.GameState.ShooterMode:
			shooterExclusiveUI.show()
			platformExclusiveUI.hide()
