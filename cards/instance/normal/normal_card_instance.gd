class_name NormalCardInstance
extends CardInstance


signal card_info_changed(new_card_info: NormalCardInfo)


@export var card_visuals: NormalCardVisuals
@export var card_info: NormalCardInfo


func _ready():
	card_visuals.set_card_info(card_info)
