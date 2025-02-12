@tool
class_name HorizontalCardContainer
extends Container

@export var spacing: float = 0.0


func _enter_tree():
	custom_minimum_size = Vector2(0, 110)
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	#if not resized.is_connected(update_child_positions):
		#resized.connect(update_child_positions)
	if not child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree, CONNECT_DEFERRED)
	update_child_positions()


func _on_child_exiting_tree(child: Node):
	custom_minimum_size.x = max(get_child_count()*80 + (get_child_count()-1)*5,0)
	size.x = custom_minimum_size.x
	update_child_positions()


func _on_child_entered_tree(child: Node):
	custom_minimum_size.x = max(get_child_count()*80 + (get_child_count()-1)*5,0)
	size.x = custom_minimum_size.x
	child.position = get_card_position(child.get_index()) + Vector2(1000,-1000)
	var tween = child.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(child, "position", get_card_position(child.get_index()), 0.5)
	tween.tween_callback(SoundManager.play_dealing_sound)


func update_child_position(child: Node):
	if not child is Control: return
	var pos = get_card_position(child.get_index())
	child.position = pos


func get_card_position(index: int):
	return Vector2(index*85,0)


func update_child_positions():
	for child in get_children():
		update_child_position(child)
	
	
	
	
	
