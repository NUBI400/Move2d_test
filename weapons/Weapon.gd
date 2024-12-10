extends Node2D
class_name Weapon


@onready var sprite: Sprite2D = $Node2D/Sprite



@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer
@onready var charge_particles: GPUParticles2D = $Node2D/Sprite/ChargeParticles



@export_enum("null", "Daggers","Straight_Swords","Greatswords","Bows","Ballistas","Reapers","Pistol","Rifle") var style: String = "null"
@export_enum("null", 'Melee', "Ranged") var range: String = "null"
@export_enum("null") var Element: String = "null"

@export var Melee_damage: int
@export var Melee_knockback: int
@export var animation_velocit: float = 1



@export var Range_projectil : PackedScene

signal animation(style, animation_velocit)
@onready var Player = get_node("../../")


func _physics_process(delta: float) -> void:
	emit_signal("animation", Player.animation_velocity(style, animation_velocit), style, animation_velocit)

func _animations(dir):
	if dir == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true


func get_input():
	animation_player.speed_scale = animation_velocit
	if Player.move_state == Player.IDLE or Player.WALK or Player.RUN and Player.crounch_state == Player.STAND and Player.jump_state == Player.FLOOR:
		if Input.is_action_just_pressed("mouse1") and not animation_player.is_playing():
			animation_player.play("attack")
		#elif Input.is_action_just_released("mouse1"):
			#if animation_player.is_playing() and animation_player.current_animation == "charge":
				#animation_player.play("attack")
			#elif charge_particles.emitting:
				#animation_player.play("strong_attack")

func is_busy() -> bool:
	if animation_player.is_playing() or charge_particles.emitting:
		return true
	return false






#
#func get_texture() -> Texture2D:
	#return get_node("Node2D/Sprite2D").texture
