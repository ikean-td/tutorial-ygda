extends CharacterBody2D
const SPEED: int = 200 
const JUMP_POWER: int = -300
const DEATH_DELAY: float = 0.2
const DISC = preload("res://scenes/disc.tscn")
const DEATHPAN = 20.0
var x_direction: int = 0
var alive: bool = true
var double_jump: bool = true
var unlock_dl: bool = false
var can_dash: bool = true
var unlock_dsh: bool = false
var runtimer = true
var dashspd = [0,0] #speed, direction
var DASHMULT: int = 500 #how fast you dash
var lastdir = 0 #stores either 1 or -1 for your last direction moved
@export var cam: Camera2D
@export var win: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if dashspd[0] > 0:
		dashspd[0] -= 10
		print(dashspd)
	else: dashspd[0] = 0
	if not is_on_floor():
		velocity += get_gravity() * delta
		if runtimer:
			$coyotetime.start() # Restart it
			runtimer = false
	if is_on_floor(): 
		runtimer = true
		can_dash = true
	if alive:
		if is_on_floor() and !double_jump and unlock_dl:
			double_jump = true
		if Input.is_action_pressed("go_left"):
			x_direction = -1
			lastdir = -1
			$AnimatedSprite2D.flip_h = true
		elif Input.is_action_pressed("go_right"):
			x_direction = 1
			lastdir = 1
			$AnimatedSprite2D.flip_h = false
		else:
			x_direction = 0
		
		if Input.is_action_just_pressed("go_jump") and (is_on_floor() or !$coyotetime.is_stopped()):
			velocity.y = JUMP_POWER
		elif Input.is_action_just_pressed("go_jump") and !is_on_floor() and double_jump and unlock_dl:
			velocity.y = JUMP_POWER
			double_jump = false
		
		if Input.is_action_just_pressed("go_dash") and can_dash and unlock_dsh:
			dashspd = [DASHMULT, lastdir]
			
		if is_on_floor():
			if x_direction != 0:
				$AnimatedSprite2D.play("run")
			else:
				$AnimatedSprite2D.play("idle")
		else:
			if velocity.y > 0:
				$AnimatedSprite2D.play("fall")
			if velocity.y < 0:
				if !double_jump:
					$AnimatedSprite2D.play("double_jump")
				else:
					$AnimatedSprite2D.play("jump")

		if Input.is_action_pressed("go_shoot") and $spotifyad.is_stopped(): # Check if player cooldown is over
			$spotifyad.start() # Restart it
			var new_disc: Area2D = DISC.instantiate() # Instanciate new disc scene
			new_disc.position = position # Set the position to the player's
			new_disc.z_index = -1
			if $AnimatedSprite2D.flip_h == true: # Check what way the player is facing
				new_disc.x_direction = -1
			else:
				new_disc.x_direction = 1
			get_tree().current_scene.add_child(new_disc) # Add it to the scene
			
		velocity.x = (x_direction * SPEED) + (dashspd[0] * dashspd[1])
	move_and_slide()

func unlocked():
	unlock_dl = true

func dashlocked():
	unlock_dsh = true

func die():
	cam.position_smoothing_speed = DEATHPAN
	print("im dead")
	alive = false
	#velocity = Vector2(0,0)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("die")
	$AnimatedSprite2D.flip_v = true
	Engine.time_scale = 0.15
	await get_tree().create_timer(DEATH_DELAY).timeout
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func e_die():
	cam.position_smoothing_speed = DEATHPAN
	print("i got jumped")
	alive = false
	velocity.y = JUMP_POWER*2
	#velocity = Vector2(0,0)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("die")
	Engine.time_scale = 0.4
	await get_tree().create_timer(DEATH_DELAY*2.5).timeout
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func youwin():
	cam.position_smoothing_enabled = false
	print("i won!")
	alive = false
	velocity.y = JUMP_POWER*4
	#velocity = Vector2(0,0)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("idle")
	var tween = get_tree().create_tween()
	tween.tween_property(win, "modulate:a", 1.0, 0.3)
	Engine.time_scale = 0.2
	await get_tree().create_timer(DEATH_DELAY*1.5).timeout
	Engine.time_scale = 1.0

func _on_tickrate_timeout() -> void: #for dash effects
	if dashspd[0] > 0:
		var cloned_node: Node = $AnimatedSprite2D.duplicate()
		#print("i clone")
		cloned_node.name = "mirage"
		get_parent().add_child(cloned_node)
		cloned_node.global_position = global_position
		cloned_node.z_index = -2
		var c: Color = cloned_node.modulate
		c.a = float(dashspd[0])/float(DASHMULT)
		cloned_node.modulate = c
		#print(global_position, cloned_node.global_position)
		var tween = get_tree().create_tween()
		tween.tween_property(cloned_node, "modulate:a", 0.0, 0.5)
		tween.tween_callback(cloned_node.queue_free)
		
