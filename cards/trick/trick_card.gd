class_name TrickCard
extends Card


@export var cost: int


func _ready() -> void:
	super()
	pressed.connect(_on_pressed)


func _on_pressed():
	if CardManager.selected_trick == self:
		CardManager.selected_trick = null
	else:
		if CardManager.selected_trick != null:
			var old_selected_trick = CardManager.selected_trick
			CardManager.selected_trick = null
			old_selected_trick.unhover()
		CardManager.selected_trick = self


func check_card_selectable(card: Card):
	return false


func select_card(card: Card):
	pass
