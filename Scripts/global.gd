extends Node2D

var name_player = "player1"


#Datos de guardado
var save_path = "user://save_game.dat"

var game_data : Dictionary = {
	"life" : 3,
	"score" : 0,
	"position" : Vector2.ZERO,
}
	


func save_game() -> void:
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	
	save_file.store_var(game_data)#Guardamos la variable
	save_file = null#Cerrarmos el archivo para que no se quede abierto durante el juego
	#Godot encripta solo el archivo de guardado para evitar que se puedan modificar y hacer tampas

func load_game() -> void:
	if FileAccess.file_exists(save_path):#Variable por si no tiene partida guardada
		var save_file = FileAccess.open(save_path, FileAccess.READ)
		
		game_data = save_file.get_var()#Cargas la variable
		save_file = null#Para cerrar el archivo
