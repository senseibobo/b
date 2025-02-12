class_name PlusTwoCard
extends TrickCard


func _ready():
	super()
	Tooltips.add_tooltip(self, "Plus Two", "Increases the rank of every 8, 9, and 10 by 2.", "")
	


func check_card_selectable(card: Card):
	if card.rank in [8,9,10]:
		return true
	return false


func select_card(card: Card):
	var selected_cards: Array
	for i in [8,9,10]:
		selected_cards.append_array(CardManager.cards_on_field[i])
	for selected_card in selected_cards:
		CardManager.modify_card_rank(selected_card, selected_card.rank + 2)
	destroy()
	CardManager.trick_performed.emit()
