extends Control

func _ready():
	visible = false

func show_death_screen() -> void:
	visible = true
	get_tree().paused = true

	var restart_button = $"res://Scenes/GUI.tscn"
	if restart_button:
		restart_button.grab_focus()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/level_inicial.tscn")
	


func _on_salir_pressed() -> void:
	get_tree().quit()
