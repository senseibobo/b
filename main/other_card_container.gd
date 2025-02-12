@tool
class_name OtherCardContainer
extends Container


const CARD_COUNT_X: int = 12
const CARD_COUNT_Y: int = 6

var card_spacing: Vector2 = Vector2()


var container_spaces: Dictionary #[Vector2i(3*24, Control]
var free_spaces: Array = []
var sort_children_queued: bool = false


func _enter_tree():
	CardManager.other_card_container = self
	update_card_spacing()
	free_spaces = []
	for i in CARD_COUNT_X:
		for j in CARD_COUNT_Y:
			container_spaces[Vector2i(i,j)] = null
			free_spaces.append(Vector2i(i,j))
	free_spaces.shuffle()
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	if not resized.is_connected(update_card_spacing):
		resized.connect(update_card_spacing)
	if not child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree)
		
	for child in get_children():
		_on_child_entered_tree(child)



#func fall_down():
	#for x in range(0, CARD_COUNT_X):
		#var fall_distance: int = 0
		#for _y in range(0, CARD_COUNT_Y):
			#var y = CARD_COUNT_Y-_y-1
			#var container_space := Vector2i(x,y)
			#var card: Card = container_spaces[container_space]
			#if card != null:
				#if fall_distance > 0:
					#var new_container_space = container_space + Vector2i(0,fall_distance)
					#container_spaces[container_space] = null
					#container_spaces[new_container_space] = card
					#card.set_meta(&"container_space", new_container_space)
					#var tween = card.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
					#tween.tween_property(card, "position", get_container_space_position(new_container_space), 0.2)
			#else:
				#fall_distance += 1
				


func _on_child_exiting_tree(child: Node):
	var container_space = child.get_meta(&"container_space", Vector2i(-1,-1))
	child.remove_meta(&"container_space")
	if container_space != Vector2i(-1,-1):
		container_spaces[container_space] = null


#func get_cards_in_row(card: Card) -> Array[Card]:
	#var y = card.get_meta(&"container_space").y
	#var row_cards: Array[Card]
	#for x in range(0, CARD_COUNT_X):
		#var row_card = container_spaces[Vector2i(x,y)]
		#if is_instance_valid(row_card) and row_card is Card:
			#row_cards.append(row_card)
	#return row_cards


func _process(delta):
	if sort_children_queued:
		sort_children_by_container_space()


func _on_child_entered_tree(child: Node):
	if child is Control:
		var container_space: Vector2i = get_free_container_space()
		container_spaces[container_space] = child
		update_child_position(child, container_space)
		child.position += Vector2(1000,-1000)
		child.set_meta(&"container_space", container_space)
		sort_children_queued = true
		var tween = child.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(child, "position", get_container_space_position(container_space), 0.5)
		tween.tween_callback(SoundManager.play_dealing_sound)


func sort_children_by_container_space():
	for i in range(0, get_child_count()-1):
		for j in range(i, get_child_count()):
			var child1 = get_child(i)
			var child2 = get_child(j)
			if child1 == child2: continue
			if compare_container_spaces(child1.get_meta(&"container_space"), child2.get_meta(&"container_space")):
				move_child(child2, child1.get_index())


func compare_container_spaces(container_space1: Vector2i, container_space2: Vector2i) -> bool:
	var cs1: int = container_space1.x*CARD_COUNT_Y + container_space1.y
	var cs2: int = container_space2.x*CARD_COUNT_Y + container_space2.y
	return cs2 < cs1


func update_children_positions():
	for container_space: Vector2i in container_spaces:
		var child = container_spaces[container_space]
		if not is_instance_valid(child): continue
		else:
			update_child_position(child, container_space)


func update_child_position(child: Control, container_space: Vector2i):
	var pos = get_container_space_position(container_space)
	child.position = pos


func get_container_space_position(container_space: Vector2i):
	var pos: Vector2 = Vector2(container_space)
	pos.x += pos.y/3.0
	pos *= card_spacing
	return pos


func get_free_container_space() -> Vector2i:
	var next_free_space: Vector2i = free_spaces.pop_front()
	free_spaces.append(next_free_space)
	return next_free_space


func update_card_spacing():
	card_spacing.x = (size.x - 160.0) / CARD_COUNT_X
	card_spacing.y = (size.y - 110.0) / CARD_COUNT_Y
	update_children_positions()	
	
	
