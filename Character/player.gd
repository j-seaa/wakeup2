extends CharacterBody2D

@export var move_speed : float = 100
@onready var sprite = $AnimatedSprite2D  # Reference to the sprite

var last_direction = "down"  # Remember last direction faced

func _physics_process(_delta):
	#Get input direction
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Normalize for diagonal movement
	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
		
		# Update animations
	if input_direction == Vector2.ZERO:
		sprite.animation = "idle_" + last_direction
	else:
		if abs(input_direction.x) > abs(input_direction.y):
			if input_direction.x > 0:
				last_direction = "right"
			else:
				last_direction = "left"
		else:
			if input_direction.y > 0:
				last_direction = "down"
			else:
				last_direction = "up"
		sprite.animation = "walk_" + last_direction
		sprite.play()
	
	#Update Velocity
	velocity = input_direction * move_speed
	
	#Move and Slide function uses velocity of character body to move character on map
	move_and_slide()
