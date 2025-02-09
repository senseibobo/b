class_name DisappearCard
extends TrickCard


func check_card_selectable(card: Card):
	return card.rank in [1,2,3,4,5,6,7,8,9,10,12]


func select_card(card: Card):
	CardManager.trick_performed.emit()
	var poof_particles = preload("res://cards/trick/disappear/poof_particles.tscn").instantiate()
	get_tree().current_scene.add_child(poof_particles)
	poof_particles.get_card_transform(card)
	destroy()
	card.destroy()
