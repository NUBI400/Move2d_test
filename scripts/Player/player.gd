extends CharacterBody2D

#WEAPONS

var current_weapon: Node2D

@onready var weapons: Node2D = $Weapons

enum {INPUT_UP, INPUT_DOWN}

signal weapon_switched(prev_index, new_index)
signal weapon_picked_up(weapon_texture)
signal weapon_droped(index)

var attack_index = 1
var max_attack_index = 3

var anim = ""

# Nodes names
@onready var sprite = $Sprite2D
@onready var Animation_player = $AnimationPlayer
@onready var colision_hitbox_ = $"Hit_box/colision_hitbox?"
@onready var colision_player = $colision_player
@onready var colision_player_troca = $colision_player_troca
@onready var camera = $Camera
@onready var slide_check = $slide_raycast
@onready var timer_attack: Timer = $timer_attack

# COLISIOES
const PLAYER_STANDING_COLISION = preload("res://Colisions/player_standing_colision.tres")
const PLAYER_COROUNCH_COLISION = preload("res://Colisions/player_crounch_colision.tres")
const PLAYER_SLIDE_COLISION = preload("res://Colisions/player_slide_colision.tres")

# STATES
var move_state = 1
var IDLE = 1
var WALK = 2
var RUN = 3
var STOP = 4
var TURN = 5

var crounch_state = 1
var STANDING = 1
var STAND = 4
var CROUNCH = 2
var CROUNCHING = 5
var SLIDE = 3
var SLIDING = 6

var jump_state = 1
var FLOOR = 1
var JUMPING = 4
var JUMP = 2
var JUMP_TO_DOWN = 6
var DOWN = 3
var DOWING = 5

var attack_state = 1
var off = 1
var on = 2


# Speed vars
var current_speed = 60.0
@export var walking_speed = 60.0
@export var running_speed = 150.0
@export var jump_speed = 150.0
@export var crouching_speed = 30.0
@export var stop_speed = 0.0
@export var turn_speed = walking_speed

@export var speed_replacement = 0.9

# RUN
var dir = 0

# Slide vars
var slide_timer = 0.0
@export var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO

@export var slide_speed = 0
var fall_distance = 0
var can_slide = false
var sliding = false 
var falling = false


#jump vars
const  JUMP_VELOCITY_STEP = 60

@export var jump_power_initial = -50
var jump_power = 0
@export var jump_time_max = 0.6
var jump_timer = 0.0

# gravity
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func STATES(delta):
	if move_state == IDLE:
		_idle(delta)
	elif move_state == WALK:
		_walk(delta)
	elif move_state == RUN:
		_run(delta)
	elif move_state == STOP:
		_stop(delta)
	elif move_state == TURN:
		_turn(delta)

	if crounch_state == STANDING:
		_standing(delta)
	if crounch_state == STAND:
		_stand(delta)
	elif crounch_state == CROUNCH:
		_crounch()
	elif crounch_state == CROUNCHING:
		_crounching()
	elif crounch_state == SLIDE:
		_slide(delta)
	elif crounch_state == SLIDING:
		_sliding(delta)

	if jump_state == FLOOR:
		_floor(delta)
	elif jump_state == JUMP:
		_jump(delta)
	elif jump_state == JUMPING:
		_jumping()
	elif jump_state == JUMP_TO_DOWN:
		_jump_to_down()
	elif jump_state == DOWN:
		_down()
	elif jump_state == DOWING:
		_dowing()


func atual_animation(delta):
	if velocity.x > 0:
		if dir != 1:
			dir = 1
			slide_check.rotation_degrees = 280
			if jump_state == FLOOR:
				move_state = TURN
	elif velocity.x < 0:
		if dir != -1:
			dir = -1
			slide_check.rotation_degrees = 80
			if jump_state == FLOOR:
				move_state = TURN

	sprite.flip_h = (dir == 1)
	
	current_weapon._animations(dir)

	if Animation_player.current_animation == "RUN":
		Animation_player.speed_scale = 2.5
		
		
		
	match attack_state:
		off:
			match move_state:
				IDLE:
					if jump_state == FLOOR:
						if crounch_state == STANDING:
							Animation_player.play("IDLE")
							current_speed = turn_speed
							colision_hitbox_.shape = PLAYER_STANDING_COLISION
							colision_player_troca.shape = PLAYER_STANDING_COLISION
						elif crounch_state == STAND:
							Animation_player.play("STAND")
							colision_hitbox_.shape = PLAYER_STANDING_COLISION
							colision_player_troca.shape = PLAYER_STANDING_COLISION
						elif crounch_state == CROUNCHING:
							Animation_player.play("CROUNCHING")
							colision_hitbox_.shape = PLAYER_COROUNCH_COLISION
							colision_player_troca.shape = PLAYER_COROUNCH_COLISION

						elif crounch_state == CROUNCH:
							Animation_player.play("CROUNCH")
							current_speed = crouching_speed 
							colision_hitbox_.shape = PLAYER_COROUNCH_COLISION
							colision_player_troca.shape = PLAYER_COROUNCH_COLISION
					else:
						_jump_state_machine(delta)
				
				
				WALK:
					if jump_state == FLOOR:
						if crounch_state == STANDING:
							Animation_player.play("WALK")
							current_speed = lerp(current_speed, walking_speed, delta * speed_replacement)
							colision_hitbox_.shape = PLAYER_STANDING_COLISION
							colision_player_troca.shape = PLAYER_STANDING_COLISION
						elif crounch_state == CROUNCH:
							Animation_player.play("CROUNCH_WALK")
							current_speed = crouching_speed
							colision_hitbox_.shape = PLAYER_COROUNCH_COLISION
							colision_player_troca.shape = PLAYER_COROUNCH_COLISION
						
						elif crounch_state == STAND:
							Animation_player.play("STAND")
							
						elif crounch_state == CROUNCHING:
							Animation_player.play("CROUNCHING")
					else:
						_jump_state_machine(delta)
				
				RUN:
					if jump_state == FLOOR:
						if crounch_state == STANDING:
							Animation_player.play("RUN")
							current_speed = lerp(current_speed, running_speed, delta * speed_replacement)
							colision_hitbox_.shape = PLAYER_STANDING_COLISION
							colision_player_troca.shape = PLAYER_STANDING_COLISION
						elif crounch_state == SLIDE:
							Animation_player.play("SLIDE")
							colision_hitbox_.shape = PLAYER_SLIDE_COLISION
							colision_player_troca.shape = PLAYER_SLIDE_COLISION
						elif crounch_state == SLIDING:
							Animation_player.play("SLIDING")
							colision_hitbox_.shape = PLAYER_STANDING_COLISION
							colision_player_troca.shape = PLAYER_STANDING_COLISION

					else:
						_jump_state_machine(delta)
				
				
				STOP:
					if jump_state == FLOOR:
						if crounch_state == STANDING:
							Animation_player.play("STOP")
						elif crounch_state == CROUNCH:
							Animation_player.play("STOP_CROUNCH")
					else:
						_jump_state_machine(delta)
				
				
				TURN:
					if jump_state == FLOOR:
						current_speed = turn_speed
						if crounch_state == STANDING:
							Animation_player.play("TURN")
							colision_hitbox_.shape = PLAYER_STANDING_COLISION
							colision_player_troca.shape = PLAYER_STANDING_COLISION
						elif crounch_state == CROUNCH:
							Animation_player.play("TURN_CROUNCH")
							colision_hitbox_.shape = PLAYER_COROUNCH_COLISION
							colision_player_troca.shape = PLAYER_COROUNCH_COLISION
					else:
						_jump_state_machine(delta)
		on:
			current_speed = 0.0
			colision_hitbox_.shape = PLAYER_STANDING_COLISION
			colision_player_troca.shape = PLAYER_STANDING_COLISION




func _jump_state_machine(delta):
	if jump_state == JUMPING:
		Animation_player.play("JUMPING")
		current_speed = lerp(current_speed, jump_speed, delta * speed_replacement)
		colision_hitbox_.shape = PLAYER_STANDING_COLISION
		colision_player_troca.shape = PLAYER_STANDING_COLISION
	elif jump_state == JUMP:
		Animation_player.play("JUMP")
		current_speed = lerp(current_speed, jump_speed, delta * speed_replacement)
		colision_hitbox_.shape = PLAYER_STANDING_COLISION
		colision_player_troca.shape = PLAYER_STANDING_COLISION
	elif jump_state == JUMP_TO_DOWN:
		Animation_player.play("JUMP_TO_DOWN")
		current_speed = lerp(current_speed, jump_speed, delta * speed_replacement)
		colision_hitbox_.shape = PLAYER_STANDING_COLISION
		colision_player_troca.shape = PLAYER_STANDING_COLISION
	elif jump_state == DOWN:
		Animation_player.play("DOWN")
		current_speed = lerp(current_speed, jump_speed, delta * speed_replacement)
		colision_hitbox_.shape = PLAYER_STANDING_COLISION
		colision_player_troca.shape = PLAYER_STANDING_COLISION
	elif jump_state == DOWING:
		Animation_player.play("DOWING")
		current_speed = lerp(walking_speed, jump_speed, delta * speed_replacement)
		colision_hitbox_.shape = PLAYER_STANDING_COLISION
		colision_player_troca.shape = PLAYER_STANDING_COLISION


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "STOP" or anim_name == "STOP_CROUNCH" or anim_name == "TURN" or anim_name == "TURN_CROUNCH":
		if velocity.x == 0:
			move_state = IDLE
		
		if velocity.x != 0 and not Input.is_action_pressed("shift") and crounch_state == STANDING:
			move_state = RUN
		if velocity.x != 0 and (Input.is_action_pressed("shift") or crounch_state != STANDING):
			move_state = WALK
	
	if anim_name == "STAND":
		crounch_state = STANDING

	if anim_name == "RUN":
		Animation_player.speed_scale = 1

	
	if anim_name == "CROUNCHING":
		crounch_state = CROUNCH
	
	if anim_name == "SLIDING":
		crounch_state = STANDING
	
	if anim_name == "JUMPING":
		move_state = IDLE
		jump_state = JUMP

	
	if anim_name == "JUMP_TO_DOWN":
		jump_state = DOWN
	
	if anim_name == "DOWING":
		move_state = IDLE
		crounch_state = STANDING
		jump_state = FLOOR
	
	if anim_name == anim + str(attack_index):
		if attack_index < max_attack_index:
			attack_index += 1
		else:
			attack_index = 1
		
		attack_state = off
		move_state = IDLE
		crounch_state = STANDING
		jump_state = FLOOR
	


func _ready():
	#emit_signal("weapon_picked_up", weapons.get_child(0).get_texture())
	current_weapon = weapons.get_child(0)
	#_restore_previous_state()
#
#func _restore_previous_state() -> void:
	#self.hp = SavedData.hp
	#for weapon in SavedData.weapons:
		#weapon = weapon.duplicate()
		#weapon.position = Vector2.ZERO
		#weapons.add_child(weapon)
		#weapon.hide()
#
		#emit_signal("weapon_picked_up", weapon.get_texture())
		#emit_signal("weapon_switched", weapons.get_child_count() - 2, weapons.get_child_count() - 1)


func _physics_process(delta):
	if falling and is_on_floor() and sliding:
		slide_speed += fall_distance/ 10
	#fall_distance = -gratr
	
	get_input()
	STATES(delta)
	atual_animation(delta)
	gravidade(delta)
	move(delta)

func get_input() -> void:
	
	if not current_weapon.is_busy():
			if Input.is_action_just_released("ui_previous_weapon"):
				_switch_weapon(INPUT_UP)
			elif Input.is_action_just_released("ui_next_weapon"):
				_switch_weapon(INPUT_DOWN)
			elif Input.is_action_just_pressed("ui_throw") and current_weapon.get_index() != 0:
				_drop_weapon()
	
	if crounch_state == STANDING and jump_state == FLOOR:
		
		if Input.is_action_just_pressed("mouse1") and attack_state == off:
			attack_state = on
			timer_attack.start()
			
			Animation_player.play(anim + str(attack_index))
			#if attack_index >= 3:
				#pode_atacar = false
				#delay_attack.start() #DELAY APOS COMBO 
				
			
		current_weapon.get_input()



func _switch_weapon(direction: int) -> void:
	var prev_index: int = current_weapon.get_index()
	var index: int = prev_index
	if direction == INPUT_UP:
		index -= 1
		if index < 0:
			index = weapons.get_child_count() - 1
	else:
		index += 1
		if index > weapons.get_child_count() - 1:
			index = 0

	current_weapon.hide()
	current_weapon = weapons.get_child(index)
	current_weapon.show()
	SavedData.equipped_weapon_index = index

	emit_signal("weapon_switched", prev_index, index)


func pick_up_weapon(weapon: Node2D) -> void:
	SavedData.weapons.append(weapon.duplicate())
	var prev_index: int = SavedData.equipped_weapon_index
	var new_index: int = weapons.get_child_count()
	SavedData.equipped_weapon_index = new_index
	weapon.get_parent().call_deferred("remove_child", weapon)
	weapons.call_deferred("add_child", weapon)
	weapon.set_deferred("owner", weapons)
	current_weapon.hide()
	current_weapon.cancel_attack()
	current_weapon = weapon

	emit_signal("weapon_picked_up", weapon.get_texture())
	emit_signal("weapon_switched", prev_index, new_index)


func _drop_weapon() -> void:
	SavedData.weapons.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Node2D = current_weapon
	_switch_weapon(INPUT_UP)


func animation_velocity(style : String, animation_velocit : float):
	Animation_player.speed_scale = animation_velocit
	anim = style


func gravidade(delta):
	if not is_on_floor() and jump_state != JUMP:
		velocity.y += (gravity /2) * delta
		falling = true
	else:
		falling = false

func move(delta):
	#if jump_state == JUMPING:
		#print("JUMPING")
	
	
	#if jump_state == DOWING:
		#print("DOWING")
	
	
	
	if not crounch_state == SLIDE:
		velocity.x = Input.get_axis("A", "D") * current_speed
	move_and_slide()



func _state_verify():
		if velocity.x != 0 and not Input.is_action_pressed("shift") and crounch_state == STANDING:
			move_state = RUN
		if velocity.x != 0 and (Input.is_action_pressed("shift") or crounch_state != STANDING):
			move_state = WALK

func _idle(delta):
	_state_verify()

func _walk(delta):
	# PARAR
	if velocity.x == 0:
		move_state = STOP
	
	
	# SAIR DO ANDANDO
	if velocity.x != 0 and not Input.is_action_pressed("shift") and crounch_state == STANDING:
		move_state = RUN

func _run(delta):
	# PARAR
	if velocity.x == 0:
		move_state = STOP
	
	# ANDAR
	if Input.is_action_pressed("shift"):
		Animation_player.speed_scale = 1
		if not crounch_state == SLIDE:
			move_state = WALK


func _stop(delta):
	pass

func _turn(delta):
	pass

func _standing(delta):
	if (move_state == IDLE or move_state == WALK) and Input.is_action_pressed("S") and jump_state == FLOOR:
		crounch_state = CROUNCHING
	
	
	
	# SLIDE
	if move_state == RUN and Input.is_action_just_pressed("S") and not is_on_wall() and jump_state == FLOOR:
		slide_speed = current_speed/1.5
		slide_timer = slide_speed/180
		slide_vector = Vector2(dir, 0) 
		move_state = RUN
		crounch_state = SLIDE

func _crounching():
	_crounch()

func _crounch():
	if Input.is_action_just_released("S") and jump_state == FLOOR:
		crounch_state = STAND

func _stand(delta):
	_standing(delta)

func _slide(delta):
	slide_timer -= delta
	if slide_timer > 0:
		velocity.x = slide_speed * slide_vector.x
		move_and_slide()
		if is_on_wall() or not is_on_floor():
			slide_timer = 0
	else:
		velocity.x = 0
		
		if Input.is_action_pressed("shift"):
			move_state = WALK
		else:
			move_state = RUN
		crounch_state = SLIDING

func _sliding(delta):
	_standing(delta)



func _floor(delta):
	if is_on_floor():   # VERIFICA SE ESTA NO CHAO E ZERA O TIMER
		jump_timer = 0.0
	else:
		jump_state = JUMP_TO_DOWN
	
	if Input.is_action_just_pressed("Space"):  #PULAR
		jump_timer = 0.0
		jump_state = JUMPING
	
	
	if Input.is_action_just_released("Space"):
		jump_timer = jump_time_max

func _jump(delta):
	jump_timer += delta
	
	if jump_timer >= jump_time_max:
		jump_state = JUMP_TO_DOWN
	
	apply_jump_force(jump_power_initial)
	jump_power = jump_power_initial
	
	if Input.is_action_pressed("Space") && jump_timer < jump_time_max: 
		jump_power -= JUMP_VELOCITY_STEP
		apply_jump_force(jump_power)
	
	if Input.is_action_just_released("Space"):
		jump_timer = jump_time_max

func _jumping():
	if Input.is_action_just_released("Space"):
		jump_timer = jump_time_max

func _jump_to_down():
	_down()

func _down():
	
	if is_on_floor():   # VERIFICA SE ESTA NO CHAO E ZERA O TIMER
		jump_state = DOWING

func _dowing():
	pass


func apply_jump_force(power):
	velocity.y = power


func _on_timer_attack_timeout() -> void:
	attack_index = 1
