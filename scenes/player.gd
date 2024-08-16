extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_VELOCITY = 600.0

@onready var sprite: Sprite2D = $Sprite

enum JumpingState {
	NORMAL, STAYING, DASHING
}

var jumping_state = JumpingState.NORMAL
var remaining_dash = 5


func _ready():
	set_remaining_dash(5)


func _physics_process(delta: float) -> void:
	if jumping_state == JumpingState.NORMAL:
		handle_normal(delta)
	elif jumping_state == JumpingState.STAYING:
		handle_staying(delta)
	elif jumping_state == JumpingState.DASHING:
		handle_dashing(delta)
	
	var collision = get_last_slide_collision()
	if collision:
		var collider_rid = collision.get_collider_rid()
		var mask = PhysicsServer2D.body_get_collision_mask(collider_rid)
		if mask == 2:
			queue_free()
			SignalHub.teleported.emit()

func handle_normal(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"): 
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		else:
			jumping_state = JumpingState.STAYING
			sprite.texture = preload("res://assets/player_dashing.png")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		sprite.flip_h = direction < 0
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func handle_staying(delta: float):
	handle_dash_input()


func handle_dashing(delta: float):
	handle_dash_input()
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumping_state = JumpingState.NORMAL
		set_remaining_dash(5)
		sprite.texture = preload("res://assets/player.png")
		
	move_and_slide()


func handle_dash_input():
	if remaining_dash == 0:
		return
	if Input.is_action_just_pressed("ui_up"):
		set_remaining_dash(remaining_dash - 1)
		jumping_state = JumpingState.DASHING
		velocity.x = 0
		velocity.y = -DASH_VELOCITY
	if Input.is_action_just_pressed("ui_down"):
		set_remaining_dash(remaining_dash - 1)
		jumping_state = JumpingState.DASHING
		velocity.x = 0
		velocity.y = DASH_VELOCITY
	if Input.is_action_just_pressed("ui_left"):
		set_remaining_dash(remaining_dash - 1)
		jumping_state = JumpingState.DASHING
		velocity.x = -DASH_VELOCITY
		velocity.y = 0
	if Input.is_action_just_pressed("ui_right"):
		set_remaining_dash(remaining_dash - 1)
		jumping_state = JumpingState.DASHING
		velocity.x = DASH_VELOCITY
		velocity.y = 0


func set_remaining_dash(amount):
	remaining_dash = amount
	SignalHub.remaining_dash_changed.emit(remaining_dash)
