@tool
class_name HandContainer
extends Container




@export var cards_out: bool = false
	


func _enter_tree():
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	if not resized.is_connected(update_child_positions):
		resized.connect(update_child_positions)
	if not child_exiting_tree.is_connected(update_child_positions.unbind(1)):
		child_exiting_tree.connect(update_child_positions.unbind(1), CONNECT_DEFERRED)
	update_child_positions()


func _ready():
	CardManager.game_started.connect(_on_next_turn)
	CardManager.trick_performed.connect(_on_next_turn)


func _on_next_turn():
	CardManager.draw_normal_cards(5)


func _process(delta):
	update_child_positions()


func update_child_positions():
	for child in get_children():
		update_child_position(child)


func update_child_position(child: Control, immediate: bool = false):
	var new_position: Vector2
	if cards_out:
		new_position.x = 40+child.get_index()%2*90 
		new_position.y = size.y - (child.get_index()*60.0)-120
	else:
		var spacing: Vector2 = Vector2.ONE*10.0
		new_position = Vector2(size.x/2.0, size.y) - child.size/2.0 + child.get_index()*spacing
	if immediate:
		child.position = new_position
	else:
		child.position = lerp(child.position, new_position, get_process_delta_time()*5.0)


func _on_child_entered_tree(child: Node):
	if not child is Control: return
	update_child_positions()
