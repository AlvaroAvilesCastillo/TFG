extends Control
func _ready():
	$VBoxContainer/Start.grab_focus()
	
	
func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_inicial.tscn")
	
	
func _on_exit_pressed():
	get_tree().quit()
