extends Node
class_name GameManager

##Misc vars
@export var paddle_speed: float = 200
@export var ball_speed: float = 150
@export var window_scale: int = 1

##Simplified Refs
@onready var window_size = get_viewport().size
@onready var r_paddle: Sprite2D = $RightPaddle
@onready var l_paddle: Sprite2D = $LeftPaddle
@onready var ui: Control = $MainUI
@onready var pause_ui: Control = $PauseUI
@onready var points_sfx: AudioStreamPlayer = $PointScoredSFX

#AI Vars
var ai_margin: float = 5

##Score vars
@export var right_score: int = 0
@export var left_score: int = 0

##Pause Vars
var repause_timer: bool = true
@export var global_speed: int = 1

##Game Settings
var left_ai: bool = false
var right_ai: bool = true
var perfect_ai: bool = false
var sfx_enable: bool = true

var ball_scene: PackedScene = preload("res://ball.tscn")
var ball: Ball

func _ready() -> void:
	spawn_ball()
	pause_ui.hide()
	

func spawn_ball() -> void:
	##Spawn new ball and add to tree
	ball = ball_scene.instantiate()
	ball.position = window_size / 2
	ball.ball_sfx = sfx_enable
	add_child(ball)
	##Connect score signal
	ball.point_scored.connect(_on_point_scored)

func _on_point_scored(side: String, old_ball_ref: Ball) -> void:
	##Determine which side scored the point and update the score var
	if side == "r":
		right_score += 1
		ui.update_r_score(right_score)
	if side == "l":
		left_score += 1
		ui.update_l_score(left_score)
	
	##Remove old ball and connections then spawn fresh ball
	old_ball_ref.point_scored.disconnect(_on_point_scored)
	old_ball_ref.queue_free()
	spawn_ball()
	
	##Play sound
	if sfx_enable:
		points_sfx.play()
	

	

func pause_game() -> void:
	##Set pause flags and chagne speed multiplier
	repause_timer = false
	global_speed = 0
	##Reapply old saved ball speed from before pause
	ball = get_tree().get_first_node_in_group("ball")
	ball_speed = ball.ball_speed
	ball.ball_speed = 0
	##Show Pause UI
	pause_ui.show()
	
func unpause_game() -> void:
	##Set pause flags and change speed multiplier
	repause_timer = false
	global_speed = 1
	##Save current ball ball speed for later; Freeze ball
	ball = get_tree().get_first_node_in_group("ball")
	ball.ball_speed = ball_speed
	##Hide Pause UI
	pause_ui.hide()

func reset_game() -> void:
	##Clear score and refresh ui
	right_score = 0
	left_score = 0
	ui.update_r_score(right_score)
	ui.update_l_score(left_score)
	pause_ui.hide()
	##Delete ball and spawn new one
	get_tree().get_first_node_in_group("ball").queue_free()
	spawn_ball()

func ai_movement(ball_pos: Vector2, side: String) -> Vector2:
	var paddle: Sprite2D
	if side == "r":
		paddle = r_paddle
	if side == "l":
		paddle = l_paddle
	
	if paddle.position.y < ball_pos.y + ai_margin:
		return Vector2.DOWN
	elif paddle.position.y > ball_pos.y - ai_margin:
		return Vector2.UP
	else:
		return Vector2.ZERO

func _process(delta: float) -> void:
	
	##Check to see is player pauses game
	if Input.is_action_just_pressed("pause"):
		if global_speed == 1:
			pause_game()
		else:
			unpause_game()
	##Check to see is player resets game
	if Input.is_action_just_pressed("reset"):
		reset_game()
	
	
	##Handle Paddle movement & input
	var l_paddle_movement: Vector2
	var r_paddle_movement: Vector2
	if not left_ai:
		l_paddle_movement = Input.get_vector("void", "void", "l_pad_up", "l_pad_down")
	else:
		l_paddle_movement = ai_movement(ball.position, "l")
		if perfect_ai:
			l_paddle_movement = Vector2.ZERO
			l_paddle.position.y = ball.position.y
	if not right_ai:
		r_paddle_movement = Input.get_vector("void", "void", "r_pad_up", "r_pad_down")
	else:
		r_paddle_movement = ai_movement(ball.position, "r")
		if perfect_ai:
			r_paddle_movement = Vector2.ZERO
			r_paddle.position.y = ball.position.y
	
	##Update paddle positions
	l_paddle.position += l_paddle_movement * paddle_speed * delta * global_speed
	r_paddle.position += r_paddle_movement * paddle_speed * delta * global_speed
	
	##Clamp paddles to window (adjusted by the scaling factor)
	l_paddle.position.y = clamp(
		l_paddle.position.y,
		l_paddle.texture.get_height() / 2 + 8,
		window_size.y - l_paddle.texture.get_height() / 2 - 8
	)
	r_paddle.position.y = clamp(
		r_paddle.position.y,
		r_paddle.texture.get_height() / 2 + 8,
		window_size.y - r_paddle.texture.get_height() / 2 - 8
	)
	


func _on_pause_timer_timeout() -> void:
	##Ensures that each press of 'esc' only counts once; no getting stuck in a pause loop!
	repause_timer = true
	$PauseTimer.start()

func _on_left_ai_toggle(toggled_on: bool) -> void:
	left_ai = toggled_on

func _on_right_ai_toggled(toggled_on: bool) -> void:
	right_ai = toggled_on

func _on_sfx_toggle(toggled_on: bool) -> void:
	sfx_enable = toggled_on
	ball = get_tree().get_first_node_in_group("ball")
	ball.ball_sfx = sfx_enable

func _on_perfect_ai_toggle(toggled_on: bool) -> void:
	perfect_ai = toggled_on
