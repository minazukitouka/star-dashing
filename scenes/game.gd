extends Node2D

@onready var camera_2d: Camera2D = $Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHub.teleported.connect(respawn)


func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("players")
	if player == null:
		return
	camera_2d.global_position = player.global_position


func respawn():
	await get_tree().create_timer(1).timeout
	var player = preload("res://scenes/player.tscn").instantiate()
	player.global_position = GameData.save_point
	add_child(player)
