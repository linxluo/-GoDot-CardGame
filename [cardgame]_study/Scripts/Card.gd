#02 - 卡牌悬停相关
#这个Area2D上有mouse_entered()和mouse_exited()方法
#这个脚本是Card的脚本,因为Area2D已经把信号连接到Card上了
#但是这是卡片的相关操作,所以把这两个信号发送给CardManager,让他来处理
extends Node2D

signal hovered
signal hovered_off

func _on_card_area_2d_mouse_entered() -> void:
	#self就是Card
	emit_signal("hovered",self)
	#print("mouse hovered enter")


func _on_card_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off",self)
	#print("mouse hovered exit")
	
func _ready() -> void:
	#get_parent()可以获得到Main场景里的CardManager
	#调用CardManager中的connect_card_signals方法来获得信号
	get_parent().connect_card_signals(self)
