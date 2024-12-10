extends Hitbox

@onready var Weapon_stats = get_node("../../..")


func _ready() -> void:
	damage = Weapon_stats.Melee_damage
	print(damage)

func _on_Hitbox_area_entered(area: Area2D) -> void:
	area.queue_free()
