extends Control

export (NodePath) onready var player = get_node(player)

onready var healthBar = get_node("CanvasLayer/Health")
onready var FPS = get_node("CanvasLayer/FPS")

func _ready():
	healthBar.max_value = player.max_health

func _process(delta):
	FPS.text = str(Engine.get_frames_per_second())
	healthBar.value = lerp(healthBar.value, ceil(player.health), 0.5)

