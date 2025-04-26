extends Node2D


func _ready():
	$AnimatedSprite2D.play("default")

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	
	var left = position[0] - $Collision.get_shape().size[0] / 2
	var right = position[0] + $Collision.get_shape().size[0] / 2
	var top = position[1] - $Collision.get_shape().size[1] / 2
	var bottom = position[1] + $Collision.get_shape().size[1] / 2
	
	if (mouse_pos[0] > left && mouse_pos[0] < right &&
			mouse_pos[1] > top && mouse_pos[1] < bottom):
		$NameTag.visible = true
	else:
		$NameTag.visible = false
		
