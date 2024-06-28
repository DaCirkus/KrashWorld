extends MarginContainer

export var item_id := "default"
onready var label = $"%Label"
onready var collectible_icon = $"%CollectibleIcon"


func _ready():
	LevelManager.connect("level_reloaded", self, "_on_level_reloaded")


func _process(_delta):
	var cdict = LevelManager.collectibles.get(item_id)
	
	if cdict:
		label.text = "%d / %d" % [cdict["collected"], cdict["total"]]


func _on_level_reloaded() -> void:
	collectible_icon.texture = LevelManager.get_current_collectible_icon()
