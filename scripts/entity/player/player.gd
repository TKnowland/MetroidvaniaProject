extends KinematicBody2D

const SNAP_LENGTH = 3.0
const SNAP_DIRECTION = Vector2.DOWN
const MAX_SPEED = 250
const MAX_GRAVITY = 450
const JUMP_FORCE = -300
const GRAVITY = 15
const UP = Vector2(0, -1)

onready var sprite = get_node("Sprite")
onready var animationPlayer = get_node("AnimationPlayer")
onready var animationTree = get_node("AnimationTree")
onready var animation = animationTree.get("parameters/playback")
onready var ledge_up = get_node("up")
onready var ledge_dw = get_node("dw")
onready var ledge_grab_timer = get_node("timers/ledge_grab")
onready var jetfuel = get_node("jetpack")
onready var floor_detect = get_node("floor")

var ground_friction = 0.15
var air_friction = 0.05
var friction = ground_friction
var acc = 0.1
var move_input
var direction
var jump_release_buffer
var is_climb :bool
var is_fly :bool
var can_jump :bool
var can_move = true
var fuel = 100
var jump_count = 0
var temp_velocity :float

var snap_vector = SNAP_DIRECTION * SNAP_LENGTH
var velocity = Vector2()


enum {
	MOVE,
	CLIMB
}
var current_state = MOVE

func _physics_process(delta):
	is_climb = (ledge_dw.is_colliding() && !ledge_up.is_colliding() && velocity.y > 20 && !floor_detect.is_colliding())
	jump_release_buffer = velocity.y < -20 && velocity.y > JUMP_FORCE
	move_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if move_input:
		ledge_dw.cast_to.x = int(ceil(move_input)) * 10
		ledge_up.cast_to.x = int(ceil(move_input)) * 10
	jetfuel.value = fuel
	if fuel < 100:
		jetfuel.visible = true
	else:
		jetfuel.visible = false
	
	match current_state:
		MOVE:
			move()
		CLIMB:
			climb()
	ledgeGrabCancel()
	velocity = move_and_slide_with_snap(velocity, snap_vector, UP)


func move():
	if move_input && can_move:
		sprite.scale.x = int(ceil(move_input))
		velocity.x = lerp(velocity.x, MAX_SPEED * move_input, acc)
		if is_on_floor():
			animation.travel("Run")
	else:
		if is_on_floor():
			animation.travel("Idle")
		velocity.x = lerp(velocity.x, 0, friction)
	if floor_detect.is_colliding():
		can_jump = true
	if Input.is_action_just_pressed("jump") && can_jump:
		velocity.y = JUMP_FORCE
		$Node2D/Jump.play()
	if is_on_floor():
		friction = ground_friction
		landImpact()
		if fuel <= 100:
			fuel += 5
		if fuel > 100:
			fuel = 100
	else:
		coyoteTime()
		friction = air_friction
		temp_velocity = velocity.y
		if Input.is_action_pressed("jetpack") && fuel > 0:
			is_fly = true
			fuel -= 4
			if velocity.y > JUMP_FORCE:
				velocity.y -= 18
		else:
			is_fly = false
		if is_climb:
			velocity.y = 0
			current_state = CLIMB
		if velocity.y < MAX_GRAVITY && !is_climb && !is_fly:
			animation.travel("Fall")
			velocity.y += GRAVITY
		if velocity.y < 0:
			animation.travel("Jump")
		if jump_release_buffer && Input.is_action_just_released("jump"):
			velocity.y = lerp(velocity.y, 0, 0.5)

func climb():
	animation.travel("LedgeGrab")
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_FORCE - 65
		ledge_dw.enabled = false
		ledge_up.enabled = false
		ledge_grab_timer.start()
		animation.travel("Jump")
		$Node2D/Jump.play()
		current_state = MOVE
	elif !ledge_dw.is_colliding():
		current_state = MOVE

func ledgeGrabCancel():
	if Input.is_action_pressed("ui_down"):
		ledge_dw.enabled = false
		ledge_up.enabled = false
		current_state = MOVE
	if Input.is_action_just_released("ui_down"):
		ledge_dw.enabled = true
		ledge_up.enabled = true

func _on_ledge_grab_timeout():
	ledge_dw.enabled = true
	ledge_up.enabled = true

func coyoteTime():
	yield(get_tree().create_timer(.1), "timeout")
	can_jump = false

func landImpact():
	if temp_velocity >= MAX_GRAVITY:
		can_move = false
		yield(get_tree().create_timer(.1), "timeout")
		can_move = true
		
