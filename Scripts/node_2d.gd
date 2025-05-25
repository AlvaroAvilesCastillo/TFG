extends Node2D

@onready var mark : Marker2D = $"../Marker2D"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.global_position = mark.position
		body.take_damage(1)


func _on_area_2d_body_exited(_body: Node2D) -> void:
	pass # Replace with function body.
