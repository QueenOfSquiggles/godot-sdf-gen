extends ViewportContainer

onready var viewport := $Viewport
onready var sprite := $Viewport/Sprite

# warning-ignore:unused_signal
signal on_completed(texture)

func process_texture(tex : Texture, kernel_size : float) -> void:
	sprite.texture = tex
	(sprite.material as ShaderMaterial).set_shader_param("kernel_size", int(kernel_size))
	viewport.size = tex.get_data().get_size()
	call_deferred("_post_render")

func _post_render() -> void:
	viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw") # wait a frame
	emit_signal("on_completed", viewport.get_texture())
