extends Node


enum GameState {
	DRAW_NORMAL,
	DRAW_TRICK,
	PERFORM_TRICK,
}


signal card_selected(card: Card)
signal trick_selected(trick: TrickCard)
signal game_started()
signal drew_normal_cards()
signal drew_trick_cards()
signal trick_performed()
signal card_rank_modified(card: Card, old_rank: int, new_rank: int)

var normal_deck: Array[Card]
var trick_deck: Array[Card]

var normal_deck_container: DeckContainer
var trick_deck_container: DeckContainer
var other_card_container: OtherCardContainer

var cards_on_field: Dictionary={1:[]}#<int, Array[Card]>
var cards_in_deck: Dictionary={1:[]}


var normal_deck_ready: bool = false
var trick_deck_ready: bool = false


var game_state: GameState
var selected_trick: TrickCard


func _enter_tree():
	for i in [1,2,3,4,5,6,7,8,9,10,12,13,14]:
		cards_on_field[i] = []
		cards_in_deck[i] = []
	cards_in_deck["trick"] = []
	cards_on_field["trick"] = []


func _ready():
	game_started.emit()
	game_started.connect(func(): game_state = GameState.DRAW_NORMAL)
	drew_normal_cards.connect(func(): game_state = GameState.DRAW_TRICK)
	drew_trick_cards.connect(func(): game_state = GameState.PERFORM_TRICK)
	trick_performed.connect(func(): game_state = GameState.DRAW_NORMAL)
	
	#while true:
		#await get_tree().create_timer(0.5).timeout
		#print(cards_on_field[1])


func move_card_to_deck(card: Card):
	if card.in_deck:
		CardManager.cards_in_deck[card.rank].erase(card)
	else:
		CardManager.cards_on_field[card.rank].erase(card)
	card.get_parent().remove_child(card)
	normal_deck_container.claim_cards([card])


func generate_normal_deck():
	for rank in [1,2,3,4,5,6,7,8,9,10,12,13,14]:
		for suit in [Card.Suit.CLUBS, Card.Suit.SPADES, Card.Suit.DIAMONDS, Card.Suit.HEARTS]:
			var card: Card = preload("res://cards/card.tscn").instantiate()
			card.setup(suit, rank)
			card.in_deck = true
			normal_deck.append(card)
			cards_in_deck[rank].append(card)
	normal_deck.shuffle()
	await normal_deck_container.claim_cards(normal_deck)
	normal_deck_ready = true
	check_game_start()
	

func generate_trick_deck():
	for i in 8:
		var disappear_card: DisappearCard = preload("res://cards/trick/disappear/disappear_card.tscn").instantiate()
		add_trick_card(disappear_card)
		var levitate: LevitateCard = preload("res://cards/trick/levitate/levitate_card.tscn").instantiate()
		add_trick_card(levitate)
	trick_deck.shuffle()
	await trick_deck_container.claim_cards(trick_deck)
	trick_deck_ready = true
	check_game_start()


func add_trick_card(trick_card: TrickCard):
	trick_deck.append(trick_card)
	trick_card.in_deck = true
	cards_in_deck["trick"].append(trick_card)


func check_game_start():
	if trick_deck_ready and normal_deck_ready:
		game_started.emit()


func modify_card_rank(card: Card, new_rank: int):
	var old_rank = card.rank
	if new_rank == 11: new_rank = 1
	card.rank = new_rank
	if card.in_deck:
		CardManager.cards_in_deck[old_rank].erase(card)
		CardManager.cards_in_deck[card.rank].append(card)
	else:
		CardManager.cards_on_field[old_rank].erase(card)
		CardManager.cards_on_field[card.rank].append(card)
	card.set_rank(card.rank)
	card_rank_modified.emit(card, old_rank, new_rank)
	


func draw_normal_cards(count: int, first_time: bool = false) -> Array[Card]:
	var drawn_cards: Array[Card] 
	if first_time:
		drawn_cards = await normal_deck_container.draw_cards(0,1,2,2,10,2)
	else:
		drawn_cards = await normal_deck_container.draw_cards(count)
	for card in drawn_cards:
		if not card: continue
		card.in_deck = false
		cards_in_deck[card.rank].erase(card)
		cards_on_field[card.rank].append(card)
	return drawn_cards


func draw_trick_cards(count: int) -> Array[Card]:
	var trick_cards = await trick_deck_container.draw_cards(count)
	for card in trick_cards:
		card.in_deck = false
		cards_in_deck["trick"].erase(card)
		cards_on_field["trick"].append(card)
	return trick_cards


func check_card_selectable(card: Card):
	if selected_trick == null:
		if card.rank == 1 and game_state == GameState.PERFORM_TRICK: 
			return true
		else:
			return false
	return selected_trick.check_card_selectable(card)


func on_card_pressed(card: Card):
	if card is TrickCard: return
	if not CardManager.game_state == CardManager.GameState.PERFORM_TRICK: return
	if check_card_selectable(card):
		if selected_trick != null:
			selected_trick.select_card(card)
		else:
			shoot_ace(card)


func shoot_ace(ace: Card):
	var target: Card = null
	var available_targets: Array
	if cards_on_field[12].size() > 0:
		available_targets = cards_on_field[12].duplicate()
	else:
		available_targets = cards_on_field[13].duplicate()
		available_targets.append_array(cards_on_field[14])
	target = available_targets.pick_random()
	var old_pos = ace.global_position
	ace.reparent(get_tree().current_scene)
	ace.global_position = old_pos
	ace.pivot_offset = Vector2(40,55)
	ace.scale = Vector2(1,1)
	var tween = create_tween().set_parallel()
	tween.tween_property(ace, "pivot_offset", Vector2(40,55),0.3).from(Vector2(40,55))
	tween.tween_property(ace, "global_position", target.global_position, 0.3)
	tween.tween_property(ace, "rotation_degrees", ace.rotation_degrees + 900, 0.3)
	await tween.finished
	target.destroy()
	ace.destroy()
	


func on_turned_into_ace(card: Card):
	AceSleeve.instance.claim_ace(card)
