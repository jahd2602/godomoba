extends KinematicBody2D

const MOTION_SPEED = 90.0

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

var current_anim = ""


func _physics_process(_delta):
	var motion = Vector2()

	if is_network_master():
		if Input.is_action_pressed("move_left"):
			motion += Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			motion += Vector2(1, 0)
		if Input.is_action_pressed("move_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			motion += Vector2(0, 1)

		# var bombing = Input.is_action_pressed("set_bomb")

		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion

	var new_anim = "standing"
	if motion.y < 0:
		new_anim = "walk_up"
	elif motion.y > 0:
		new_anim = "walk_down"
	elif motion.x < 0:
		new_anim = "walk_left"
	elif motion.x > 0:
		new_anim = "walk_right"

	if new_anim != current_anim:
		current_anim = new_anim
		get_node("anim").play(current_anim)

	# FIXME: Use move_and_slide
	move_and_slide(motion * MOTION_SPEED)
	if not is_network_master():
		puppet_pos = position # To avoid jitter


func set_player_name(new_name):
	get_node("label").set_text(new_name)


func _ready():
	puppet_pos = position
