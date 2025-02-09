class_name TrickCard
extends Card


@export var cost: int


func _ready() -> void:
	super()
	pressed.connect(_on_pressed)
	CardManager.trick_performed.connect(deselect)


func deselect():
	if CardManager.selected_trick == self:
		CardManager.selected_trick = null
		unhover()

func select():
	if CardManager.game_state == CardManager.GameState.PERFORM_TRICK:
		if CardManager.selected_trick != null:
			var old_selected_trick = CardManager.selected_trick
			CardManager.selected_trick = null
			old_selected_trick.unhover()
		CardManager.selected_trick = self


func _on_pressed():
	if CardManager.selected_trick == self:
		deselect()
	else:
		select()


func check_card_selectable(card: Card):
	return false


func select_card(card: Card):
	pass


func destroy():
	if in_deck:
		CardManager.cards_in_deck["trick"].erase(self)
	else:
		CardManager.cards_on_field["trick"].erase(self)
	queue_free()


func update_face_texture():
	pass
