class_name MainScene
extends Control


@export var king_queen_container: HorizontalCardContainer
@export var jack_container: HorizontalCardContainer
@export var other_card_container: OtherCardContainer
@export var hand_container: HandContainer
@export var card_scene: PackedScene
@export var trick_card_scene: PackedScene


func _ready():
	SoundManager.play_music(preload("res://audio/music/battle_music.ogg"))
	CardManager.game_started.connect(draw_normal_cards.bind(true))
	CardManager.trick_performed.connect(draw_normal_cards)
	CardManager.drew_normal_cards.connect(draw_trick_cards)
	CardManager.card_rank_modified.connect(_on_card_rank_modified)


func _on_card_rank_modified(card: Card, old_rank: int, new_rank: int):
	var t1: int
	var t2: int
	match old_rank:
		2,3,3,4,5,6,7,8,9,10: t1 = 1
		1: t1 = 2
		12: t1 = 3
		13,14: t1 = 4
	match new_rank:
		2,3,3,4,5,6,7,8,9,10: t2 = 1
		1: t2 = 2
		12: t2 = 3
		13,14: t2 = 4
	if t1 != t2:
		await remove_card(card)
		add_card(card)


func draw_normal_cards(first_time: bool = false):
	var cards = await CardManager.draw_normal_cards(5, first_time)
	for card in cards:
		if not card: continue
		add_card(card)
		await get_tree().create_timer(0.05).timeout
	CardManager.drew_normal_cards.emit()


func draw_trick_cards():
	var trick_cards_in_hand: int = CardManager.cards_on_field["trick"].size()
	var cards = await CardManager.draw_trick_cards(4-trick_cards_in_hand)
	for card in cards:
		add_trick_card(card)
	CardManager.drew_trick_cards.emit()


func add_trick_card(card: TrickCard):
	hand_container.add_child(card)


func add_card(card: Card):
	var container: Container
	if card.rank == 14 or card.rank == 13: container = king_queen_container
	elif card.rank == 12: container = jack_container
	else: container = other_card_container
	container.add_child(card)
	card.setup(card.suit, card.rank)


func remove_card(card: Card):
	var tween = card.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(card,"position",card.position + Vector2(1000,-1000),0.5)
	await tween.finished
	card.get_parent().remove_child(card)
	
	
