extends Camera2D

var shake_amount = 0
var default_offset = offset
var shake :bool
onready var tween = get_node("Tween")
onready var timer = get_node("Timer")

export (NodePath) onready var player = get_node(player)
export (float) var lerpspeed = 0.1


func _ready():
	randomize()
	Global.camera = self
	shake = false


func _process(delta):
	self.position = lerp(self.position, player.position, lerpspeed)
	if shake:
		offset = Vector2(rand_range(-1, 1) * shake_amount, rand_range(-1, 1) * shake_amount)
	
func _shake(time, amount):
	shake = true
	timer.wait_time = time
	shake_amount = amount
	timer.start()

func _on_Timer_timeout():
	shake = false
	tween.interpolate_property(self, "offset", offset, default_offset, 0.1, 6, 2)
	tween.start()
