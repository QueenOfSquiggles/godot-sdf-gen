extends Control

export (int) var kernel_size := 4
export (Color) var target_colour := Color.black
export (float) var colour_range := 0.01

onready var input_preview := $"%InputPreview"
onready var output_preview := $"%OutputPreview"
onready var output_smoothed := $"%OutputSmoothed"
onready var check_use_complete_sound : CheckBox = $"%CheckUseCompleteSound"
onready var render_engine := $"%RenderingEngine"
onready var check_safety := $"%CheckSafety"
onready var slider_kernel_size := $"%KernelSize"
onready var margins := $Content
onready var audio_player := $AudioStreamPlayer

const SAFETY_MAX_KERNEL := 64.0

func _ready():
	var img := load("res://icon.png") as Texture
	_set_from_loaded_image(img.get_data())


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
	_set_from_loaded_image(loaded_image)

func _set_from_loaded_image(img : Image) -> void:
	var texture := ImageTexture.new()
	texture.create_from_image(img, 0)
	input_preview.texture = texture

func _generate() -> void:
	print("generating...")
	render_engine.process_texture(input_preview.texture, kernel_size)

func _on_RenderingEngine_completed(texture : Texture):
	print("processing completed")
	output_preview.texture = texture
	texture.flags = Texture.FLAG_FILTER
	output_smoothed.texture = texture
	yield(VisualServer, "frame_post_draw")
	if check_use_complete_sound.pressed:
		audio_player.call_deferred("play")

func _on_KernelSize_value_changed(value):
	kernel_size = value
	if check_safety.pressed and kernel_size > SAFETY_MAX_KERNEL:
		slider_kernel_size.value = SAFETY_MAX_KERNEL
		

func _on_BtnSave_pressed():
	var file_dialog := FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.size_flags_horizontal = SIZE_EXPAND_FILL
	file_dialog.add_filter("*.png ; PNG file")
	file_dialog.size_flags_vertical = SIZE_EXPAND_FILL
	margins.add_child(file_dialog)
	var _clr = file_dialog.connect("confirmed", self, "_on_save_image", [file_dialog])
	file_dialog.popup_centered(Vector2(720, 480))

func _on_save_image(file_dialog : FileDialog) -> void:
	var path := file_dialog.current_path
	var img : Image = output_preview.texture.get_data()
	if not path.ends_with(".png"):
		path = path + ".png"
	var err := img.save_png(path)
	if err != OK:
		push_warning("failed to save file")



