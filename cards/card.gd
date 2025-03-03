class_name Card
extends Control


signal pressed


static var hovered_card: Card

enum Suit {
	SPADES,
	CLUBS,
	DIAMONDS,
	HEARTS,
}


@export var suit: Suit
@export var rank: int #11-A 12-J 13-Q 14-K
@export var suit_color: Color

@export var card_face_texture_rect: TextureRect
@export var top_card_rank_texture_rect: TextureRect
@export var bottom_card_rank_texture_rect: TextureRect
@export var top_card_suit_texture_rect: TextureRect
@export var bottom_card_suit_texture_rect: TextureRect
@export var card_selectable_color_rect: ColorRect
@export var card_back_face_texture_rect: TextureRect

var hovered: bool = false
var tween: Tween
var in_deck: bool = true:
	set(value):
		card_back_face_texture_rect.visible = in_deck
		in_deck = value
	get:
		return in_deck



func _enter_tree():
	card_back_face_texture_rect.visible = in_deck


func _ready():
	card_selectable_color_rect.visible = false
	setup(suit,rank)
	pass
	#setup(Suit.values().pick_random(), randi()%14+1)


func setup(suit: Suit, rank: int):
	set_suit(suit)
	set_rank(rank)


func set_suit(suit: Suit):
	self.suit = suit
	var suit_texture: Texture2D
	var suit_color: Color
	match suit:
		Suit.SPADES: 
			suit_texture = preload("res://textures/spades.svg")
		Suit.CLUBS: 
			suit_texture = preload("res://textures/clubs.svg")
		Suit.DIAMONDS: 
			suit_texture = preload("res://textures/diamonds.svg")
		Suit.HEARTS:
			suit_texture = preload("res://textures/hearts.svg")
	bottom_card_suit_texture_rect.texture = suit_texture
	top_card_suit_texture_rect.texture = suit_texture
	update_suit_color()
	update_face_texture()


func set_rank(rank: int):
	if rank == 11: rank = 1
	self.rank = rank
	var rank_texture: Texture2D
	match rank:
		1: rank_texture = preload("res://textures/a.svg")
		2: rank_texture = preload("res://textures/2.svg")
		3: rank_texture = preload("res://textures/3.svg")
		4: rank_texture = preload("res://textures/4.svg")
		5: rank_texture = preload("res://textures/5.svg")
		6: rank_texture = preload("res://textures/6.svg")
		7: rank_texture = preload("res://textures/7.svg")
		8: rank_texture = preload("res://textures/8.svg")
		9: rank_texture = preload("res://textures/9.svg")
		10: rank_texture = preload("res://textures/10.svg")
		12: rank_texture = preload("res://textures/j.svg")
		13: rank_texture = preload("res://textures/q.svg")
		14: rank_texture = preload("res://textures/k.svg")
	top_card_rank_texture_rect.texture = rank_texture
	bottom_card_rank_texture_rect.texture = rank_texture
	if rank == 1 and not in_deck:
		CardManager.on_turned_into_ace(self)
	update_face_texture()


func update_face_texture():
	if not rank in [1,2,3,4,5,6,7,8,9,10,12,13,14]: return
	var rank_string: String = str(rank)
	var extension: String = ".svg"
	if rank == 1: rank_string = "a"
	elif rank == 12: rank_string = "jack"
	elif rank == 13: rank_string = "queen"
	elif rank == 14: rank_string = "king"
	var suit_string: String
	match suit:
		Suit.SPADES: suit_string = "spades"
		Suit.HEARTS: suit_string = "hearts"
		Suit.CLUBS: suit_string = "clubs"
		Suit.DIAMONDS: suit_string = "diamonds"
	if rank in [12,13,14]:
		extension = ".png"
		suit_string = "any"
		
	var face_texture: Texture2D = load("res://textures/middle/"+rank_string+"-"+suit_string+extension)
	card_face_texture_rect.texture = face_texture


func update_suit_color():
	var color: Color
	if suit in [Suit.SPADES, Suit.CLUBS]: color = Color.BLACK
	else: color = Color("#eb4034")
	top_card_rank_texture_rect.modulate = color
	bottom_card_rank_texture_rect.modulate = color


func _on_mouse_entered() -> void:
	hover()


func _on_mouse_exited() -> void:
	unhover()


func _process(delta):
	if has_meta(&"container_space"):
		$DebugLabel.text = str(get_meta(&"container_space"))
		$DebugLabel.visible = false
	else:
		$DebugLabel.visible = false


func hover():
	SoundManager.play_hover_sound()
	card_selectable_color_rect.visible = CardManager.check_card_selectable(self)
	hovered = true
	pivot_offset = size/2.0
	if hovered_card != null: hovered_card.unhover()
	hovered_card = self
	z_index = 5
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1.2,1.2), 0.2)


func unhover():
	card_selectable_color_rect.visible = false
	hovered = false
	if hovered_card == self: hovered_card = null
	z_index = 0
	if not CardManager.selected_trick == self:
		if tween and tween.is_running(): tween.kill()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.1)


func destroy(randomize_rank: bool = false):
	CardManager.move_card_to_deck(self)
	var kings = CardManager.cards_on_field[14]
	var queens = CardManager.cards_on_field[13]
	if kings.size() == 0 and queens.size() == 0: 
		if is_instance_valid(get_tree()):
			get_tree().change_scene_to_file("res://menus/game_over.tscn")
	if randomize_rank:
		set_rank([2,3,4,5,6,7,8,9,10].pick_random())


func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if hovered and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()
			CardManager.on_card_pressed(self)
