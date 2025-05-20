extends Node2D

@onready var mark : Marker2D = $"../Marker2D"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.global_position = mark.position


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
