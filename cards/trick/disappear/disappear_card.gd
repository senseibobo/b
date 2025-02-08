class_name DisappearCard
extends TrickCard


func check_card_selectable(card: Card):
	return card.rank in [1,2,3,4,5,6,7,8,9,10,12]


func select_card(card: Card):
	card.queue_free()
	queue_free()
