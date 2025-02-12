class_name NormalCardInfo
extends CardInfo


signal suit_changed(new_suit: Suit)
signal rank_changed(new_rank: int)


@export var suit: Suit:
	set(value): suit = value; suit_changed.emit(value)
	get: return suit
@export var rank: int: #11-A 12-J 13-Q 14-K
	set(value): rank = value; rank_changed.emit(value)
	get: return rank


func increase_rank(amount: int):
	rank = posmod(rank+amount-1, 14) + 1
	if rank == 11: rank = 1
	rank_changed.emit(rank)


func decrease_rank(amount: int):
	increase_rank(-amount)
	
