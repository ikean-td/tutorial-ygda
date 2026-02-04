extends Area2D

const SPEED: int = 300

var x_direction: int = 1

func _physics_process(delta: float) -> void:
	position.x += SPEED * x_direction * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.queue_free() # Destroy the enemy

	if not body.is_in_group("player"):
		queue_free() # Destroy the disc if the body isn't the player

func _times_up() -> void:
	queue_free()
