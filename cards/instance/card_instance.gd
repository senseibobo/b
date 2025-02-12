class_name CardInstance
extends Control


signal hovered()
signal unhovered()
signal pressed()
signal released()
signal clicked()


func _on_mouse_entered() -> void:
	hovered.emit()


func _on_mouse_exited() -> void:
	unhovered.emit()
