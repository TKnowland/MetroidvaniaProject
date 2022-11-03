extends Control

export (NodePath) onready var player = get_node(player)

onready var healthBar = get_node("CanvasLayer/Health")

func _ready():
	healthBar.max_value = player.max_health

func _process(delta):
	healthBar.value = lerp(healthBar.value, player.health, 0.4)

