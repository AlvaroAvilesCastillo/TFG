extends CharacterBody2D
class_name TrainingDummy

@export_category("Combat")
@export var max_life: int = 999999  #vida

@onready var anim_sprite: AnimatedSprite2D = $Sprite2D  

var life: int = max_life
var is_hit: bool = false

func _ready() -> void:
	# Añadir al grupo de enemigos
	add_to_group("enemy")
	
	# Conectar señal de animación si existe
	if anim_sprite:
		anim_sprite.animation_finished.connect(_on_animated_sprite_animation_finished)

func _physics_process(_delta: float) -> void:
	
	if not is_hit:
		if anim_sprite and anim_sprite.animation != "idle":
			anim_sprite.play("idle")


func take_damage(amount: int) -> void:
	print("Dummy recibió daño: ", amount)
	if is_hit:
		print("Dummy ya está en animación de golpe")
		return  

	
	is_hit = true
	print("Reproduciendo animación de golpe")
	
	
	if anim_sprite:
		print("AnimatedSprite2D encontrado, reproduciendo 'hit'")
		if anim_sprite.sprite_frames.has_animation("hit"):
			anim_sprite.play("hit")
		else:
			print("Error: No existe la animación 'hit'")
			print("Animaciones disponibles: ", anim_sprite.sprite_frames.get_animation_names())
	else:
		print("Error: No se encontró el nodo AnimatedSprite2D")


func _on_animated_sprite_animation_finished() -> void:
	if anim_sprite.animation == "hit":
		is_hit = false
		anim_sprite.play("idle")
