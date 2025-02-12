@tool
class_name DeckContainer
extends Container


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
	CardManager.call("generate_"+deck_name+"_deck")


func _on_child_entered_tree(child: Node):
	update_child_positions()


func update_child_position(child: Node):
	child.position = get_child_position(child.get_index())


func get_child_position(index: int):
	return Vector2.ONE * index * 1.0


func update_child_positions():
	for child in get_children():
		update_child_position(child)


func draw_cards(any: int, jacks: int = 0, queens: int = 0, kings: int = 0, normal: int = 0, aces: int = 0) -> Array[Card]:
	var drawn_cards: Array[Card]
	var last_tween: Tween
	var cards_to_draw: Array[Card] = []
	
	cards_to_draw.append_array(get_top_n_cards(1, aces))
	cards_to_draw.append_array(get_top_n_cards(12, jacks))
	cards_to_draw.append_array(get_top_n_cards(13, queens))
	cards_to_draw.append_array(get_top_n_cards(14, kings))
	cards_to_draw.append_array(get_top_n_normal_cards(normal))
	var children: Array = get_children()
	children.reverse()
	for i in any:
		if children.size() == 0: break
		if i >= children.size(): break
		var card = children[i]
		if not card is Card: 
			any += 1
			continue
		if card in cards_to_draw: 
			any += 1
			continue
		cards_to_draw.append(card)
	
				
	for card in cards_to_draw:
		if get_child_count() == 0: break
		drawn_cards.append(card)
		var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		SoundManager.play_draw_sound()
		tween.tween_property(card, "position", card.position + Vector2(1000,-1000), 0.8)
		tween.tween_property(card, "in_deck", false, 0.0)
		tween.tween_callback(remove_child.bind(card))
		last_tween = tween
		await get_tree().create_timer(0.03).timeout
	if last_tween and last_tween.is_running():
		await last_tween.finished
	return drawn_cards


func get_top_n_cards(rank: int, count: int) -> Array[Card]:
	var cards: Array[Card]
	if count <= 0: return cards
	var children: Array = get_children()
	children.reverse()
	for card: Node in children:
		if not card is Card: continue
		if card.rank == rank:
			cards.append(card)
			count -= 1
			if count <= 0:
				break
	return cards


func get_top_n_normal_cards(count: int) -> Array[Card]:
	var cards: Array[Card]
	if count <= 0: return cards
	var children: Array = get_children()
	children.reverse()
	for card: Node in children:
		if not card is Card: continue
		if not card.rank in [12,13,14,1]:
			cards.append(card)
			count -= 1
			if count <= 0:
				break
	return cards 

	
func claim_cards(cards: Array[Card], from_bottom: bool = false):
	var last_tween: Tween
	for card in cards:
		card.in_deck = true
		add_child(card)
		if from_bottom:
			move_child(card,0)
			card.z_index = -10
		var child_dest_position: Vector2 = get_child_position(0 if from_bottom else get_child_count()-1)
		card.position = child_dest_position + Vector2(1000,-1000)
		var tween = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "position", child_dest_position, 0.8)
		tween.tween_property(card, "z_index", 0, 0.0)
		tween.tween_callback(SoundManager.play_flick_sound)
		last_tween = tween
		if not is_instance_valid(get_tree()): return
		await get_tree().create_timer(0.03).timeout
		
	if last_tween and last_tween.is_running():
		await last_tween.finished
	
