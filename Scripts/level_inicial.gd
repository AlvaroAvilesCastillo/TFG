extends Node2D

var ruta = ""
@onready var marker_2d: Marker2D = $Marker2D

func _ready() -> void:
	cargar_personaje()

func _process(delta):
		if Input.is_action_just_pressed("e") and ruta != "":
			get_tree().change_scene_to_file(ruta)

func cargar_personaje():
	if Global.name_player == "player1":
		var instanciate_player = preload("res://Scenes/Player.tscn").instantiate()
		instanciate_player.global_position = marker_2d.global_position
		add_child(instanciate_player)
	

func _on_portal_1_body_entered(body):
	if body.is_in_group("player"):
		ruta = ""


func _on_portla_2_body_entered(body):
	if body.is_in_group("player"):
		ruta = "res://Scenes/level_cemetery.tscn"


func _on_portal_1_body_exited(body):
	ruta = ""
	


func _on_portla_2_body_exited(body):
	ruta = ""
