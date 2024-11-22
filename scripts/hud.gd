extends Control

@onready var target = %TextureRect

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func target_state(state):
	if state:
		target.modulate.a = 1.0
	else:
		target.modulate.a = 0.5
