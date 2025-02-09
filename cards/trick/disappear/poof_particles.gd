extends Control


func _ready():
	$Control/GPUParticles2D.emitting = true
	var tween = create_tween()
	tween.tween_property($ColorRect,"modulate:a", 0.0, 0.5)
	await get_tree().create_timer(2.0).timeout
	queue_free()


func get_card_transform(card: Card):
	if not card.is_inside_tree(): return
	self.pivot_offset = card.pivot_offset
	self.scale = card.scale
	self.global_position = card.global_position
