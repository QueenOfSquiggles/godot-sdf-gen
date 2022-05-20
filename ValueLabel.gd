extends Label

export (NodePath) var target_node : NodePath

onready var target := get_node(target_node)

func _process(_delta : float) -> void:
	self.text = "Value: %s" % str(target.value)
