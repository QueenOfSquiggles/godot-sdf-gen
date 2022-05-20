extends Panel

onready var slider := $MarginContainer/VBoxContainer/HBoxContainer/HSlider
onready var image := $"%OutputSmoothed"

func _ready():
	var _clr := slider.connect("value_changed", self, "_on_threshold_changed")

func _on_threshold_changed(value : float) -> void:
	var shader_material := image.material as ShaderMaterial
	shader_material.set_shader_param("density_threshold", value / 100.0)
