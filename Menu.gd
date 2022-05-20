extends Control

export (int) var kernel_size := 2
export (Color) var target_colour := Color.black
export (float) var colour_range := 0.01

onready var input_preview := $"%InputPreview"
onready var output_preview := $"%OutputPreview"
onready var output_smoothed := $"%OutputSmoothed"
onready var colour_pick :ColorPicker= $"%ColorPicker"
onready var allowance_slider : HSlider = $"%AllowanceSlider"
onready var margins := $Content

func _ready():
	var _clr := colour_pick.connect("color_changed", self, "_on_colour_picked")
	_clr = allowance_slider.connect("value_changed", self, "_allowance_changed")

func _on_colour_picked(col : Color)-> void:
	target_colour = col

func _allowance_changed(value : float) -> void:
	colour_range = value

func _open_file() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.size_flags_horizontal = SIZE_EXPAND_FILL
	file_dialog.size_flags_vertical = SIZE_EXPAND_FILL
	file_dialog.add_filter("*.png ; PNG Images")
	file_dialog.add_filter("*.jpg ; JPG Images")
	file_dialog.add_filter("*.jpeg ; JPEG Images")
	margins.add_child(file_dialog)
	var _clr = file_dialog.connect("file_selected", self, "_on_file_selected")
	file_dialog.popup_centered(Vector2(720, 480))

func _on_file_selected(path : String) -> void:
	var loaded_image := Image.new()
	var err := loaded_image.load(path)
	if err != OK:
		push_warning("Failed to load image %s" % path)
		return
	var texture := ImageTexture.new()
	texture.create_from_image(loaded_image, 0)
	input_preview.texture = texture

func _generate() -> void:
	var img := input_preview.texture.get_data() as Image
	var img_out := Image.new()
	
	img_out.copy_from(img) # literally just copying core params, all data will be replaced
	img.lock() # OMFG ALWAYS LOCK & UNLOCK YOUR IMAGES
	img_out.lock()
	
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var min_dist := float(img.get_height())
			var source_pos := Vector2(x, y)
			var target_pos := source_pos
			var source_col := img.get_pixelv(source_pos)
			if _colour_distance(source_col, target_colour) <= colour_range:
				min_dist = 0.0
			else:
				for i in range(-kernel_size, kernel_size+1):
					for k in range(-kernel_size, kernel_size+1):
						var local_pos := Vector2(i, k)
						if local_pos.length() > kernel_size:
							continue
						target_pos = source_pos + local_pos
						if target_pos.x >= 0 and target_pos.y >= 0 and target_pos.x < img.get_width() and target_pos.y < img.get_height():
							var sample_col := img.get_pixelv(target_pos)
							if _colour_distance(sample_col, target_colour) <= colour_range:
								min_dist = min(min_dist, local_pos.length())
					if min_dist <= 0.0:
						break # quick break if we get a short enough distance
			# assign pixel colour to new SDF
			var grey := 1.0 - clamp(min_dist / float(kernel_size), 0.0, 1.0)
			var col := Color(grey, grey, grey)
			img_out.set_pixelv(source_pos, col)
	img.unlock()
	img_out.unlock()
	var texture := ImageTexture.new()
	texture.create_from_image(img_out, 0)
	output_preview.texture = texture
	texture.flags = Texture.FLAG_FILTER
	output_smoothed.texture = texture
	

func _colour_distance(a : Color, b : Color) -> float:
	# approximate distance in terms of colour
	var rd := abs(a.r - b.r)
	var gd := abs(a.g - b.g)
	var bd := abs(a.b - b.b)
	var ad := abs(a.a - b.a)
	return (rd + gd + bd + ad) / 4.0
