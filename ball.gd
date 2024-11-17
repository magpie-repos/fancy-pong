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
	while abs(direction.x) < 0.4 && abs(direction.x) != 0.5: #Ensure there is some movement along x axis
		while abs(direction.y) < 0.2: #Ensure there is movement along the y axis
			direction = Vector2(randf_range( -1.0, 1.0), randf_range( -1.0, 1.0)).normalized()

func _physics_process(delta: float) -> void:
	var velocity: Vector2 = direction * ball_speed * delta
	var collision: KinematicCollision2D = move_and_collide(velocity)

	if collision:
		direction = (direction.bounce(collision.get_normal())).normalized()
		if collision.get_collider().get_parent().is_in_group("paddle"):
			ball_speed += 25
			paddle_sfx.play()
			paddle_sfx.pitch_scale += 0.05
			wall_sfx.pitch_scale += 0.05
		else:
			wall_sfx.play()
		
	position += direction * ball_speed * delta
	
	if position.x < $Sprite2D.texture.get_width() * -1:
		point_scored.emit("r", self)
	if position.x > get_viewport().size.x + $Sprite2D.texture.get_width():
		point_scored.emit("l", self)

	
	
