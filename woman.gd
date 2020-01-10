extends KinematicBody2D

const UP = Vector2(0, -1)

export var gravity = 600
export var max_speed: = Vector2(100, 200)
export var speed: = Vector2(1800, 200)
export var coyote_time = 0.1
export var friction_ground = 0.5
export var friction_air = 0.05

var velocity: = Vector2(0, 0)
var time_since_on_floor: = 0.0
var has_jumped: = false

# TODO: Program in the 'Weapon' class. Player will have one weapon to start, with abstract methods
# e.g. 'fire'
func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("fire"):
		$Sprite/pistol/AnimationPlayer.play("fire")
	
	if has_jumped && is_on_floor():
		has_jumped = false
	
	var direction: Vector2 = get_direction()

	if direction.x > 0.0:
		$Sprite.flip_h = false
		$Sprite/pistol.flip_h = false
		$Sprite/pistol.position.x = 6
		$Sprite/AnimationPlayer.play("run")
	elif direction.x < 0.0:
		$Sprite.flip_h = true
		$Sprite/pistol.flip_h = true
		$Sprite/pistol.position.x = -6
		$Sprite/AnimationPlayer.play("run")
	elif is_on_floor() && !Input.is_action_pressed("fire"):
		$Sprite/pistol/AnimationPlayer.queue("idle")
		$Sprite/AnimationPlayer.play("stand")

	if !is_on_floor():
		time_since_on_floor += delta
		if velocity.y < 0:
			$Sprite/AnimationPlayer.play("jump")
		else:
			$Sprite/AnimationPlayer.play("fall")
	else:
		time_since_on_floor = 0

	velocity = move_and_slide(calculate_veclocity(direction), UP)

func calculate_veclocity(direction: Vector2) -> Vector2:
	var delta = get_physics_process_delta_time()
	var vel = velocity
	vel.x += speed.x * delta * direction.x

	if direction.x == 0:
		vel.x = lerp(vel.x, 0, friction_ground)

	if Input.is_action_just_pressed("jump") && can_jump():
		var strength = Input.get_action_strength("jump")
		vel.y = -speed.y * strength
		time_since_on_floor = 0
		has_jumped = true

	if vel.y < 0 && !is_on_floor() && Input.is_action_just_released("jump"):
		vel.y /= 5

	vel.y = clamp(vel.y + gravity * delta, -max_speed.y, max_speed.y)

	if !is_on_floor():
		vel.x = lerp(vel.x, 0, friction_air)

	vel.x = clamp(vel.x, -max_speed.x, max_speed.x)

	return vel

func get_direction() -> Vector2:
	var x: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y: float = -1.0 if Input.is_action_just_pressed("jump") && can_jump() else 1.0
	return Vector2(x, y)

func can_jump() -> bool:
	return !has_jumped && (is_on_floor() || time_since_on_floor <= coyote_time)
