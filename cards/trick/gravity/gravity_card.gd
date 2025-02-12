class_name GravityCard
extends TrickCard



func _ready():
	super()
	Tooltips.add_tooltip(self, "Gravity", "Lowers every card down towards the bottom row.", "")


func select_card(card: Card):
	CardManager.other_card_container.fall_down()
	destroy()
	CardManager.trick_performed.emit()


func check_card_selectable(card: Card):
	return true
