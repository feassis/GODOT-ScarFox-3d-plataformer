extends ColorRect
class_name ReloadBulletUI

@export_category("Objects")
@export var arrow : Sprite2D
@export var startPoint: Control
@export var endPoint: Control
@export var quickReloadArea: ColorRect

func Setup(quickReloadPercentil: float, quickReloadPercentilSize: float):
	var startToEndVector = GetStartToEndVector()
	quickReloadArea.position = Vector2(startToEndVector.x * quickReloadPercentil , quickReloadArea.position.y)
	quickReloadArea.size.x = startToEndVector.x * quickReloadPercentilSize
	
func UpdateArrowPosition(arrowPercentil: float):
	var startToEndVector = GetStartToEndVector()
	arrow.position = Vector2(startToEndVector.x * arrowPercentil, arrow.position.y)
	
func GetStartToEndVector() -> Vector2:
	return endPoint.position - startPoint.position
