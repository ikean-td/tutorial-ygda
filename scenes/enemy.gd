extends CharacterBody2D

const SPEED: int = 50
var x_direction = 1

func _physics_process(_delta: float) -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.is_in_group("player"):
			collider.e_die()

	if is_on_wall():
		x_direction *= -1


	velocity.x = SPEED * x_direction
	move_and_slide()
