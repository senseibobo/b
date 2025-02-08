@tool
class_name AceSleeve
extends Container


static var instance: AceSleeve

@export var start_ace_position: Vector2 = Vector2():
	set(value):
		start_ace_position = value
		update_child_positions()
	get:
		return start_ace_position
@export var ace_spacing: Vector2 = Vector2(10,10):
	set(value):
		ace_spacing = value
		update_child_positions()
	get:
		return ace_spacing


var aces: Array[Card]


func _enter_tree():
	instance = self
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	if not child_exiting_tree.is_connected(update_child_positions.unbind(1)):
		child_exiting_tree.connect(update_child_positions.unbind(1))
	if not resized.is_connected(update_child_positions):
		resized.connect(update_child_positions)
	

func _on_child_entered_tree(child: Node):
	update_child_position(child)


func update_child_position(child: Node):
	if not child is Control: return
	child.global_position = get_ace_position(child.get_index())


func get_ace_position(index: int):
	return global_position + start_ace_position + ace_spacing*index


func update_child_positions():
	for child in get_children():
		update_child_position(child)


func _exit_tree() -> void:
	if instance == self: instance = null


func get_next_ace_position():
	return get_ace_position(aces.size())


func claim_ace(card: Card):
	aces.append(card)
	var old_position: Vector2 = card.global_position
	var parent: Node = card.get_parent()
	parent.remove_child(card)
	get_tree().current_scene.add_child(card)
	card.global_position = old_position
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var new_pos = get_next_ace_position()
	tween.tween_property(card, "global_position", new_pos, 1.0)
	await tween.finished
	get_tree().current_scene.remove_child(card)
	add_child(card)
	card.global_position = new_pos
