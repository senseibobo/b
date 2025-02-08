@tool
class_name DeckContainer
extends Container


@export var draw_cards_check: bool = false:
	set(value):
		if value:
			var drawn_cards = await draw_cards(6)
			claim_cards(drawn_cards)
	get:
		return false

@export var deck_name: String = "normal"


func _enter_tree():
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	if not resized.is_connected(update_child_positions):
		resized.connect(update_child_positions)
	if not child_exiting_tree.is_connected(update_child_positions.unbind(1)):
		child_exiting_tree.connect(update_child_positions.unbind(1), CONNECT_DEFERRED)
	update_child_positions()


func _ready():
	CardManager.set(deck_name+"_deck_container", self)


func _on_child_entered_tree(child: Node):
	update_child_positions()


func update_child_position(child: Node):
	child.position = get_child_position(child.get_index())


func get_child_position(index: int):
	return Vector2.ONE * index * 1.0


func update_child_positions():
	for child in get_children():
		update_child_position(child)


func draw_cards(count: int) -> Array[Card]:
	var drawn_cards: Array[Card]
	var last_tween: Tween
	for i in count:
		if get_child_count() == 0: break
		var top_card = get_child(-i-1)
		drawn_cards.append(top_card)
		var tween: Tween = top_card.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tween.tween_property(top_card, "position", top_card.position + Vector2(1000,-1000), 0.8)
		tween.tween_property(top_card, "in_deck", false, 0.0)
		tween.tween_callback(remove_child.bind(top_card))
		last_tween = tween
		await get_tree().create_timer(0.03).timeout
	if last_tween and last_tween.is_running():
		await last_tween.finished
	return drawn_cards
	
	
func claim_cards(cards: Array[Card]):
	var last_tween: Tween
	for card in cards:
		add_child(card)
		var child_dest_position: Vector2 = get_child_position(card.get_index())
		card.position = child_dest_position + Vector2(1000,-1000)
		var tween = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "position", child_dest_position, 0.8)
		last_tween = tween
		await get_tree().create_timer(0.03).timeout
	if last_tween and last_tween.is_running():
		await last_tween.finished
	
