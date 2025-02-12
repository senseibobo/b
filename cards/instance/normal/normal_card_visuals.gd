class_name NormalCardVisuals
extends CardVisuals

@export var card_info: NormalCardInfo
@export var top_suit_sprite: Sprite2D
@export var top_rank_sprite: Sprite2D
@export var bottom_suit_sprite: Sprite2D
@export var bottom_rank_sprite: Sprite2D
@export var middle_sprite: Sprite2D


func set_card_info(card_info: NormalCardInfo):
	self.card_info = card_info
	update_sprites()
	card_info.rank_changed.connect(update_sprites_animated.unbind(1))
	card_info.suit_changed.connect(update_sprites_animated.unbind(1))


func update_sprites_animated():
	spin_x2()
	await spin_animation_middle
	update_sprites()


func update_sprites():
	top_suit_sprite.texture = get_suit_texture(card_info.suit)
	bottom_suit_sprite.texture = top_suit_sprite.texture
	top_rank_sprite.texture = get_rank_texture(card_info.rank)
	bottom_rank_sprite.texture = top_rank_sprite.texture
	middle_sprite.texture = get_middle_texture(card_info.rank, card_info.suit)
	set_rank_suit_sprites_modulate(Color.RED if card_info.suit in [CardInfo.Suit.HEARTS, CardInfo.Suit.DIAMONDS] else Color.BLACK)


func set_rank_suit_sprites_modulate(new_modulate: Color):
	top_suit_sprite.modulate = new_modulate
	bottom_suit_sprite.modulate = new_modulate
	top_rank_sprite.modulate = new_modulate
	bottom_rank_sprite.modulate = new_modulate


func get_rank_texture(rank: int) -> Texture2D:
	match rank:
		1: return preload("res://textures/ranks/a.svg")
		2: return preload("res://textures/ranks/2.svg")
		3: return preload("res://textures/ranks/3.svg")
		4: return preload("res://textures/ranks/4.svg")
		5: return preload("res://textures/ranks/5.svg")
		6: return preload("res://textures/ranks/6.svg")
		7: return preload("res://textures/ranks/7.svg")
		8: return preload("res://textures/ranks/8.svg")
		9: return preload("res://textures/ranks/9.svg")
		10: return preload("res://textures/ranks/10.svg")
		12: return preload("res://textures/ranks/j.svg")
		13: return preload("res://textures/ranks/q.svg")
		14: return preload("res://textures/ranks/k.svg")
	return null


func get_suit_texture(suit: CardInfo.Suit) -> Texture2D:
	match suit:
		CardInfo.Suit.CLUBS: return preload("res://textures/suits/clubs.svg")
		CardInfo.Suit.SPADES: return preload("res://textures/suits/spades.svg")
		CardInfo.Suit.HEARTS: return preload("res://textures/suits/hearts.svg")
		CardInfo.Suit.DIAMONDS: return preload("res://textures/suits/diamonds.svg")
	return null


func get_middle_texture(rank: int, suit: CardInfo.Suit) -> Texture2D:
	if not rank in [1,2,3,4,5,6,7,8,9,10,12,13,14]: return null
	var rank_string: String = str(rank)
	var extension: String = ".svg"
	if rank == 1: rank_string = "a"
	elif rank == 12: rank_string = "jack"
	elif rank == 13: rank_string = "queen"
	elif rank == 14: rank_string = "king"
	var suit_string: String
	if rank in [12,13,14]:
		extension = ".png"
		suit_string = "any"
	else:
		match suit:
			CardInfo.Suit.SPADES: suit_string = "spades"
			CardInfo.Suit.HEARTS: suit_string = "hearts"
			CardInfo.Suit.CLUBS: suit_string = "clubs"
			CardInfo.Suit.DIAMONDS: suit_string = "diamonds"
	return load("res://textures/middle/"+rank_string+"-"+suit_string+extension)
	
