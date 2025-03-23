extends Node2D

const COLLISION_MASK_CARD = 1
#判断哪张卡牌为拖动状态
var card_being_dragged
#当前鼠标位置
var mouse_pos
#卡片位置和鼠标点击位置的偏移量
var mouse_card_pos_offset
#屏幕尺寸
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size
	pass
	
func _process(delta: float) -> void:
	#如果当前有卡牌在被拖动,那么获取鼠标的位置
	if card_being_dragged:
		mouse_pos = get_global_mouse_position()
		#设置被拖动的卡牌的位置,clamp夹紧函数让卡牌不会出视口
		card_being_dragged.position = Vector2(clamp((mouse_pos + mouse_card_pos_offset).x,0,screen_size.x),
			clamp((mouse_pos + mouse_card_pos_offset).y,0,screen_size.y))
		
	
#检测鼠标左键点击
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			print("Left Mouse Button Click")
			#用射线检测左键点击的时候是否有卡牌
			var card = raycast_check_for_card()
			#如果当前点击有卡牌,那么将当前卡牌作为拖动状态
			if card:
				card_being_dragged = card
				#计算鼠标位置和当前卡牌位置的偏移量
				find_card_mouse_position_offset(card)

		else:
			print("Left Mouse Button Release")
			#松开鼠标左键视为取消卡牌拖动状态
			card_being_dragged = null

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
		return result[0].collider.get_parent()
	return null
