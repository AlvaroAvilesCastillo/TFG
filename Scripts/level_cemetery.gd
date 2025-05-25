extends Node2D

var ruta = ""
@onready var marker_2d: Marker2D = $Marker2D

func _ready() -> void:
	var music = $AudioStreamPlayer
	if music.stream is AudioStream:
		music.stream.loop = true 
	music.play()
	
	cargar_personaje()


func _process(delta):
		if Input.is_action_just_pressed("e") and ruta != "":
			get_tree().change_scene_to_file(ruta)

func cargar_personaje():
	if GLOBAL.name_player == "player1":
		var instanciate_player = preload("res://Scenes/Player.tscn").instantiate()
		instanciate_player.global_position = marker_2d.global_position
		add_child(instanciate_player)


func _on_portal_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		ruta = "res://Scenes/level_mountain.tscn"
	

func _on_portal_1_body_exited(body: Node2D) -> void:
	ruta = ""
