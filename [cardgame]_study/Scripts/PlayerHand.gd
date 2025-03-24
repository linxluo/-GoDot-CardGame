extends Node2D

#04 - 玩家手牌
#玩家手牌数量
const HAND_COUNT = 8
#卡牌场景路径
const CARD_SCENE_PATH = "res://Scene/Card.tscn"
#玩家所有的卡牌数组
var player_hand = []
#屏幕宽度
var center_screen_x
#卡牌宽度
const CARD_WIDTH = 200
#手牌的Y坐标
const HAND_Y_POSITION = 890

func _ready() -> void:
	#获取屏幕x轴的中间位置
	center_screen_x = get_viewport().size.x/2
	print(center_screen_x)
	#preload加载场景
	var card_scene = preload(CARD_SCENE_PATH)
	#循环创建卡牌
	for i in range(HAND_COUNT):
		var new_card = card_scene.instantiate()
		$"../CardManager".add_child(new_card)
		new_card.name = "Card"
		add_card_to_hand(new_card)
	pass # Replace with function body.

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions()
	else:
		animate_card_to_position(card,card.hand_position)
		
#更新卡牌的位置
func update_hand_positions():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i),HAND_Y_POSITION)
		var card = player_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card,new_position)
		
#卡片移动到位置的动画
func animate_card_to_position(card,new_position):
	var tween  = get_tree().create_tween()
	tween.tween_property(card,"position",new_position,0.1)
	
#计算手牌中的卡片在哪个位置
func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index  * CARD_WIDTH - total_width / 2
	return x_offset

#从手牌移除卡牌
func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()
