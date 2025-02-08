class_name MainScene
extends Control


@export var king_queen_container: HBoxContainer
@export var jack_container: HBoxContainer
@export var other_card_container: OtherCardContainer
@export var hand_container: HandContainer
@export var card_scene: PackedScene
@export var trick_card_scene: PackedScene


func _ready():
	pass


func add_trick_card(card: TrickCard):
	CardManager.trick_cards.append(card)
	hand_container.add_child(card)


func add_card(card: Card):
	var container: Container
	if card.rank == 14 or card.rank == 13: 
		CardManager.kings_queens.append(card)
		container = king_queen_container
	elif card.rank == 12: 
		CardManager.jacks.append(card)
		container = jack_container
	else: 
		CardManager.other_cards.append(card)
		container = other_card_container
	CardManager.all_cards.append(card)
	container.add_child(card)
	card.setup(card.suit, card.rank)
	
	
