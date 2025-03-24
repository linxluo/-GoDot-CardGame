extends Node2D

#01 - 卡牌拖动相关
#卡牌碰撞MASK
const COLLISION_MASK_CARD = 1
#判断哪张卡牌为拖动状态
var card_being_dragged
#当前鼠标位置
var mouse_pos
#卡片位置和鼠标点击位置的偏移量
var mouse_card_pos_offset
#屏幕尺寸
var screen_size

#02 - 卡牌悬停相关
var is_hovering_on_card

var now_hover_card

#03 - 卡槽相关
#卡槽碰撞MASK
const COLLISION_MASK_CARD_SLOT = 2
func _ready() -> void:
	#01 - 卡牌拖动相关
	screen_size = get_viewport_rect().size
	pass
	
func _process(delta: float) -> void:
	#01 - 卡牌拖动相关
	#如果当前有卡牌在被拖动,那么获取鼠标的位置
	if card_being_dragged:
		mouse_pos = get_global_mouse_position()
		#设置被拖动的卡牌的位置,clamp夹紧函数让卡牌不会出视口
		card_being_dragged.position = Vector2(clamp((mouse_pos + mouse_card_pos_offset).x,0,screen_size.x),
			clamp((mouse_pos + mouse_card_pos_offset).y,0,screen_size.y))
	
#01 - 卡牌拖动相关
#检测鼠标左键点击
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			print("Left Mouse Button Click")
			#用射线检测左键点击的时候是否有卡牌
			var card = raycast_check_for_card()
			#如果当前点击有卡牌,那么将当前卡牌作为拖动状态
			if card:
				start_drag(card)
				#计算鼠标位置和当前卡牌位置的偏移量
				find_card_mouse_position_offset(card)
		else:
			print("Left Mouse Button Release")
			#松开鼠标左键视为取消卡牌拖动状态
			if card_being_dragged:
				finish_drag()

func _notification(what) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			#02 - 卡牌悬停相关
			#如果在高亮显示的过程中,鼠标移出游戏视口,那么就把当前高亮的卡牌取消高亮
			print("鼠标移出窗口")
			print(now_hover_card)
			highlight_card(now_hover_card,false)
			is_hovering_on_card = false

#计算鼠标位置和当前卡牌位置的偏移量
func find_card_mouse_position_offset(card):
	var card_pos = card.position
	mouse_pos = get_global_mouse_position()
	mouse_card_pos_offset = card_pos - mouse_pos	

#射线检测左键点击的时候是否有卡牌
#有卡牌就返回Card.tscn对象
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var paramters = PhysicsPointQueryParameters2D.new()
	paramters.position = get_global_mouse_position()
	paramters.collide_with_areas = true
	paramters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(paramters)
	if result.size()>0:
		#print(result)
		#这个有个问题就是 两张牌重叠的时候 射线检测会随机让一张牌作为result[0]
		#return result[0].collider.get_parent()
		#获得最top的那张卡片,也就是z_index最大的那个
		return get_card_with_highest_z_index(result)
	return null

#获得z_index最大的卡牌
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1,cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

#02 - 卡牌悬停相关
#获得Card下Area2D发来的信号
func connect_card_signals(card):
	card.connect("hovered",on_hovered_over_card)
	card.connect("hovered_off",on_hovered_over_card_off)

#鼠标悬停在卡牌上
func on_hovered_over_card(card):
	#判断是否已经悬停在卡牌上了
	#防止当两张牌有部分重叠的时候
	#当前如果已经有高亮显示的卡牌,那么就不会高亮显示后进入的那张牌
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card,true)
		now_hover_card = card
		print("hovred")
	#当鼠标在拖动状态下在视口外拖动回来,不要改变卡牌的大小
	if NOTIFICATION_WM_MOUSE_ENTER:
		if card_being_dragged:
			print(card_being_dragged)
			highlight_card(now_hover_card,false)
			card_being_dragged.scale = Vector2(1,1)
			
#鼠标离开悬停的卡牌上
func on_hovered_over_card_off(card):
	#拖动状态时,会离开其他的卡片,不要恢复卡片原来大小的效果
	if !card_being_dragged:
		#离开当前悬停的卡牌的时候就恢复卡牌原来的大小
		highlight_card(card,false)
		#防止当两张牌有部分重叠的时候
		#虽然不会高亮显示后进入的牌,但是先前进入的牌已经进入到hover_off状态
		#进行射线检测,查看是否还在先前进入的牌
		#是的话就重新高亮显示先前进入的牌
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered,true)
		#不是的话就可以将牌缩小到原来的大小了
		else:
			is_hovering_on_card = false
		print("hovered off")
	
#卡牌高亮(放大)显示
func highlight_card(card,hovered):
	if hovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1,1)
		card.z_index = 1

#卡牌拖动反馈
func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1,1)
	pass
	
func finish_drag():
	#02 - 卡牌悬停效果
	if NOTIFICATION_WM_MOUSE_EXIT:
		card_being_dragged.scale = Vector2(1,1)
	else:
		card_being_dragged.scale = Vector2(1.05,1.05)
	
	#03 - 卡槽判断
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		card_being_dragged.position = card_slot_found.position
		#放进卡槽后就不能移动了
		card_being_dragged.get_node("CardArea2D/CardCollider").disabled = true
		#当前卡槽是有卡牌了
		card_slot_found.card_in_slot = true
	card_being_dragged = null
	pass

#03 - 卡槽相关
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var paramters = PhysicsPointQueryParameters2D.new()
	paramters.position = get_global_mouse_position()
	paramters.collide_with_areas = true
	paramters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(paramters)
	if result.size()>0:
		return result[0].collider.get_parent()
	return null
