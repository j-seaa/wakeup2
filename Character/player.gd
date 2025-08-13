extends CharacterBody2D

@export var move_speed: float = 100
@onready var sprite = $AnimatedSprite2D

# Assign in Inspector
@export var dialogue_label: RichTextLabel
@export var table_area: Area2D
@export var bed_area: Area2D
@export var next_scene: PackedScene

# State
var cutscene_playing = false
var dialogue_lines: Array = []
var current_line = 0
var last_direction = "down"

func _ready():
	dialogue_label.visible = false
	table_area.body_entered.connect(_on_table_body_entered)
	bed_area.body_entered.connect(_on_bed_body_entered)

func _physics_process(_delta):
	if cutscene_playing:
		velocity = Vector2.ZERO
		sprite.animation = "idle_" + last_direction
		sprite.play()
		return

	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
		if abs(input_direction.x) > abs(input_direction.y):
			last_direction = "right" if input_direction.x > 0 else "left"
		else:
			last_direction = "down" if input_direction.y > 0 else "up"
		sprite.animation = "walk_" + last_direction
		sprite.play()
	else:
		sprite.animation = "idle_" + last_direction

	velocity = input_direction * move_speed
	move_and_slide()

func _input(event):
	if cutscene_playing and event.is_action_pressed("click"):
		show_next_line()

# -----------------------
# Table Trigger
# -----------------------
func _on_table_body_entered(body):
	if body == self and not cutscene_playing:
		start_dialogue([
			"Player: Ugh… I can’t believe it’s already so late.",
			"Player: I set my alarm earlier, but now I can’t even find it...",
			"Player: I need to wake up on time tomorrow, or I’ll be late again.",
			"Player: Did I leave it on the table? Or maybe on the desk?",
			"Player: I’ve looked everywhere… it’s nowhere to be found.",
			"Player: This anxiety is making me more tired…",
			"Player: Maybe I should just go to bed now and trust I’ll wake up on time.",
			"Player: I’ll set everything up in my mind before sleeping so tomorrow goes smoothly."
		])

# -----------------------
# Bed Trigger
# -----------------------
func _on_bed_body_entered(body):
	if body == self:
		get_tree().change_scene_to(next_scene)

# -----------------------
# Start Dialogue
# -----------------------
func start_dialogue(lines: Array):
	if cutscene_playing:
		return
	cutscene_playing = true
	dialogue_lines = lines
	current_line = 0
	dialogue_label.bbcode_text = dialogue_lines[current_line]
	dialogue_label.visible = true

# -----------------------
# Show Next Line
# -----------------------
func show_next_line():
	current_line += 1
	if current_line < dialogue_lines.size():
		dialogue_label.bbcode_text = dialogue_lines[current_line]
	else:
		dialogue_label.visible = false
		cutscene_playing = false
