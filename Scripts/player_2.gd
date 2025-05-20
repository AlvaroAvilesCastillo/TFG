extends CharacterBody2D
class_name player2

var axis : Vector2 = Vector2.ZERO
var death : bool = false

@export var gui : CanvasLayer

@export var speed : int = 128
@export var gravity : int = 16
@export var jump : int = 450
@export var life : int = 3


func _process(_delta):
	match death:
		true:
			death_ctrl()
		false:
			motion_crtl()
				

func _input(event):
	if not death and is_on_floor() and event.is_action_pressed("ui_accept") :
		jump_ctrl(1)

func get_axis() -> Vector2: #Funcion para retomar la direccion
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis.normalized()

func motion_crtl() -> void:
	'''MOVIMIENTO'''
	#Linea para controlar hacia donde mira el personaje
	if not get_axis().x == 0:
		$AnimatedSprite2D.scale.x = get_axis().x
	
	velocity.x = get_axis().x * speed
	velocity.y += gravity
	
	move_and_slide()
	
	'''ANIMACIONES'''
	match is_on_floor():
		true: #Si toca el suelo entra aqui para ver si corre o no corre
			if not get_axis().x == 0:
				$AnimatedSprite2D.set_animation("run")
			else:
				$AnimatedSprite2D.set_animation("idle")
		false:#Si no toca el suelo entra aqui
			if velocity.y < 0:#Si velocity.y es menor que 0 significa que esta subiendo
				$AnimatedSprite2D.set_animation("jump")
			else:#Si no esta en caida
				$AnimatedSprite2D.set_animation("jump")

func death_ctrl() -> void:
	velocity.x = 0 #Quitamos la direccion del eje x
	velocity.y += gravity #Si muere no se queda flotando en el aire
	move_and_slide()

func jump_ctrl(power : float) -> void:
	velocity.y = -jump * power
	#Audio/Salto.play()

func damage_ctrl() -> void:
	death = true
	$AnimatedSprite2D.set_animation("death")

func _on_hit_point_body_entered(body):
	if body is Enemy and velocity.y >= 0:
		#$Audio/Hit.play()
		body.damage_ctrl(1)
		jump_ctrl(0.75)

func _on_sprite_animation_finished():
	if $AnimatedSprite2D.animation == "Death":
		gui.game_over()
		
