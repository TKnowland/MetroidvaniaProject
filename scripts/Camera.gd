extends Camera2D


export (NodePath) onready var player = get_node(player)

export (float) var lerpspeed = 0.1

func _process(delta):
	self.position = lerp(self.position, player.position, lerpspeed)
