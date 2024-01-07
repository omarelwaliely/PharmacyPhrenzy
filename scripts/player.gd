extends CharacterBody3D

#head node
@onready var head = $head

#speed
var curr_speed = 5.0
@export var  walking_speed = 5.0
@export var sprint_speed  = 8.0
@export var crouch_speed  = 3.0
@export var mouse_sensitivity  = 0.4
@export var crouch_amount = -0.5
const jump_velocity = 4.5

#collision body
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape

#upwards raycast
@onready var ray_cast_3d = $RayCast3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
func _input(event):
	#mouse movement
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y*mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-90), deg_to_rad(90),)
		
func _physics_process(delta):
	#handling gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	#crouch
	if Input.is_action_pressed("crouch"):
		curr_speed = crouch_speed
		head.position.y = 1.5 + crouch_amount
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	elif !ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = 1.5
		#sprinting
		if Input.is_action_pressed("sprint"):
			curr_speed = sprint_speed
		#walking
		else:
			curr_speed = walking_speed

	#jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	#movement
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * curr_speed
		velocity.z = direction.z * curr_speed
	else:
		velocity.x = move_toward(velocity.x, 0, curr_speed)
		velocity.z = move_toward(velocity.z, 0, curr_speed)
	move_and_slide()
