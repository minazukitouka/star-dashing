extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(set_last_save_point)


func set_last_save_point(body):
	if not body.is_in_group("players"):
		return
	GameData.save_point = global_position
	queue_free()
