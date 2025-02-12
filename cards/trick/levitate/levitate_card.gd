class_name LevitateCard
extends TrickCard

func _ready():
	super()
	Tooltips.add_tooltip(self, "Levitate", "Increases the ranks of every card in the row by 1.", "")

func check_card_selectable(card: Card):
	return card.rank in [2,3,4,5,6,7,8,9,10]


func select_card(card: Card):
	var all_cards: Array[Card] = CardManager.other_card_container.get_cards_in_row(card)
	for row_card: Card in all_cards:
		CardManager.modify_card_rank(row_card, row_card.rank+1)
		var poof_particles = preload("res://cards/trick/disappear/poof_particles.tscn").instantiate()
		get_tree().current_scene.add_child(poof_particles)
		poof_particles.global_position = row_card.global_position
	destroy()
	CardManager.trick_performed.emit()
