extends Node


signal card_selected(card: Card)
signal trick_selected(trick: TrickCard)
signal game_started()
signal drew_normal_cards()
signal drew_trick_cards()
signal trick_performed()

var normal_deck: Array[Card]
var trick_deck: Array[TrickCard]

var normal_deck_container: DeckContainer
var trick_deck_container: DeckContainer

var trick_cards: Array[TrickCard]
var kings_queens: Array[Card]
var jacks: Array[Card]
var other_cards: Array[Card]
var all_cards: Array[Card]


var selected_trick: TrickCard
var aces: int = 0


func _enter_tree():
	generate_normal_deck()
	generate_trick_deck()


func _ready():
	game_started.emit()


func generate_normal_deck():
	for rank in [1,2,3,4,5,6,7,8,9,10,12,13,14]:
		for suit in [Card.Suit.CLUBS, Card.Suit.SPADES, Card.Suit.DIAMONDS, Card.Suit.HEARTS]:
			var card: Card = preload("res://cards/card.tscn").instantiate()
			card.setup(suit, rank)
			card.in_deck = true
			normal_deck.append(card)
	normal_deck.shuffle()


func generate_trick_deck():
	for i in 8:
		var disappear_card: DisappearCard = preload("res://cards/trick/disappear/disappear_card.tscn").instantiate()
		trick_deck.append(disappear_card)
		disappear_card.in_deck = true
	trick_deck.shuffle()


func draw_normal_cards(count: int) -> Array[Card]:
	var drawn_cards = await normal_deck_container.draw_cards(count)
	return drawn_cards


func draw_trick_cards(count: int) -> Array[Card]:
	var trick_cards = await trick_deck_container.draw_cards(count)
	return trick_cards


func check_card_selectable(card: Card):
	if selected_trick == null: return false
	return selected_trick.check_card_selectable(card)


func on_card_pressed(card: Card):
	if card is TrickCard: return
	if check_card_selectable(card):
		selected_trick.select_card(card)


func on_turned_into_ace(card: Card):
	AceSleeve.instance.claim_ace(card)
