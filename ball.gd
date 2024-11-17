extends RigidBody2D
class_name Ball

##Initial values
var direction: Vector2 = Vector2.ZERO
var ball_speed: float = 150
var ball_sfx: bool = true

##Audio Refs
@onready var paddle_sfx: AudioStreamPlayer2D = $PaddleBounceSFX
@onready var wall_sfx: AudioStreamPlayer2D = $WallBounceSFX

signal point_scored

func _ready() -> void:
	add_to_group("ball")
	
	##Spawn the ball with a randomized vector
	direction = Vector2(randf_range( -1.0, 1.0), randf_range( -1.0, 1.0)).normalized()
	if direction.x < 0:#Safeties to make sure the direction is fun and won't loop
		direction.x = -1
	else:
		direction.x = 1
	if abs(direction.y) < 0.2:
		direction.y = 0.2

func _physics_process(delta: float) -> void:
	var velocity: Vector2 = direction * ball_speed * delta
	var collision: KinematicCollision2D = move_and_collide(velocity)

	if collision:
		direction = (direction.bounce(collision.get_normal())).normalized()
		if collision.get_collider().get_parent().is_in_group("paddle"):
			ball_speed += 25
			if ball_sfx:
				paddle_sfx.play()
			paddle_sfx.pitch_scale += 0.05
			wall_sfx.pitch_scale += 0.05
		else:
			if ball_sfx:
				wall_sfx.play()
		
	position += direction * ball_speed * delta
	
	if position.x < $Sprite2D.texture.get_width() * -1:
		point_scored.emit("r", self)
	if position.x > get_viewport().size.x + $Sprite2D.texture.get_width():
		point_scored.emit("l", self)

	
	
