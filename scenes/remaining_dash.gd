extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHub.remaining_dash_changed.connect(update_bar)


func update_bar(amount):
	value = amount
