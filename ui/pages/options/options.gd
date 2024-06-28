extends Control

onready var master_volume_slider = $"%MasterVolumeSlider"
onready var music_volume_slider = $"%MusicVolumeSlider"

func _ready():
	yield(get_tree(), "idle_frame")
	connect("visibility_changed", self, "_on_visibility_changed")
	refresh()
	
	master_volume_slider.connect("value_changed", self, "_on_master_volume_value_changed")
	music_volume_slider.connect("value_changed", self, "_on_music_volume_value_changed")
	


func refresh() -> void:
	master_volume_slider.value = ClientSettings.master_volume*100.0
	music_volume_slider.value = ClientSettings.music_volume*100.0


func _on_MainMenu_pressed():
	EventBus.emit_signal("menu_requested")


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		refresh()


func _on_master_volume_value_changed(new_value: float) -> void:
	ClientSettings.master_volume = new_value*0.01



func _on_music_volume_value_changed(new_value: float) -> void:
	ClientSettings.music_volume = new_value*0.01
