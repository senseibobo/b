class_name MinusTwoCard
extends TrickCard


func _ready():
	super()
	Tooltips.add_tooltip(self, "Minus Two", "Decreases the rank of every 2, 3, and 4 by 2.", "")
	
	
func check_card_selectable(card: Card):
	if card.rank in [2,3,4]:
		return true
	return false


func select_card(card: Card):
	var selected_cards: Array
	for i in [2,3,4]:
		selected_cards.append_array(CardManager.cards_on_field[i])
	for selected_card in selected_cards:
		CardManager.modify_card_rank(selected_card, selected_card.rank - 2)
	destroy()
	CardManager.trick_performed.emit()
