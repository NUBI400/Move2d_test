extends Node2D
@onready var particles: GPUParticles2D = $Node2D/Particles
@onready var animation_player: AnimationPlayer = $Node2D/AnimationPlayer
@onready var sprite_2d: Sprite2D = $Node2D/Sprite2D


@export var Damage: int
@export var range: int
@export var Knockback: int
