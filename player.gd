extends KinematicBody2D

const MOTION_SPEED = 90.0

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

var current_anim = ""

var world_target_pos = Vector2()


func _physics_process(_delta):
	var motion = Vector2()

	if is_network_master(): # Means: The current player is this machine
		# Move towards the target pos
		if world_target_pos != Vector2(): # If it is not the initial target pos
			if position.distance_to(world_target_pos) > 1: # If we are far
				motion = position.direction_to(world_target_pos) 

		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion
		
	move_and_slide(motion * MOTION_SPEED)
	
	if not is_network_master():
		puppet_pos = position # To avoid jitter
		
	# Update the target position, aka Flag
	$target.global_position = world_target_pos
	
	animate_character(motion)

# Animate the character sprite towards the direction its moving
func animate_character(motion: Vector2) -> void:
#	print(motion)
	var new_anim = "standing"
	if motion.length() > 0:
		
		var direction_number := int(round(( motion.angle()+PI) / PI * 2))
		match direction_number:
			0:
				new_anim = "walk_left"
			1:
				new_anim = "walk_up"
			2:
				new_anim = "walk_right"
			3:
				new_anim = "walk_down"
			4: 
				new_anim = "walk_left"

	if new_anim != current_anim:
		current_anim = new_anim
		get_node("anim").play(current_anim)


func set_player_name(new_name):
	get_node("label").set_text(new_name)


func _ready():
	puppet_pos = position
	
func _unhandled_input(event: InputEvent) -> void:
	if is_network_master():
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_RIGHT and event.pressed:
				set_world_target_pos(event.global_position)
	
func set_world_target_pos(world_pos: Vector2) -> void:
	world_target_pos = world_pos
	print(name)
	if is_network_master():
		print("master set_world_target_pos")
	else:
		print("puppet set_world_target_pos")
	
	
	
