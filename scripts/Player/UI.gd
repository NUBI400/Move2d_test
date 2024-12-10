extends CanvasLayer

@onready var player = $".."


@onready var label = $Labels/Label

@onready var label_2 = $Labels/Label2

@onready var label_3 = $Labels/Label3



func _physics_process(delta):
	label.text = str("move_state   ", player.move_state)
	label_2.text = str("crounch_state   ", player.crounch_state)
