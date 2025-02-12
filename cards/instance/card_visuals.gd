class_name CardVisuals
extends CanvasGroup


signal spin_animation_middle()
signal spin_animation_finished()


@export var card_front: Sprite2D
@export var card_back: Sprite2D
@export var animation_player: AnimationPlayer

var front_visible: bool = true
var hovered: bool = false


func _process(delta):
	scale = scale.lerp(Vector2(1,1) + Vector2.ONE*0.1*int(hovered), 15*delta)


func spin():
	animation_player.play(&"spin")


func spin_x2():
	animation_player.play(&"spin_x2")
	

func toggle_front_visible():
	set_card_side_visible(not front_visible)


func set_card_side_visible(front: bool):
	front_visible = front
	card_front.visible = front
	card_back.visible = not front


func _on_spin_middle():
	spin_animation_middle.emit()
	toggle_front_visible()


func _on_spin_finished():
	spin_animation_finished.emit()


func _on_card_instance_hovered() -> void:
	hovered = true


func _on_card_instance_unhovered() -> void:
	hovered = false
