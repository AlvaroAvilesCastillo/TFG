extends CharacterBody2D
class_name PlayerCharacter2

@export_category("Movement")
@export var speed: int = 128
@export var gravity: int = 16
@export var jump_force: int = 450

@export_category("Combat")
@export var max_life: int = 3
@export var attack_damage: int = 1 
@export var invulnerability_time: float = 1.5

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var life: int = max_life
var attacking: bool = false
var invulnerable: bool = false
var death: bool = false
var facing_right: bool = true  # Variable para rastrear la dirección del jugador

signal player_hit(current_life: int, max_life: int)
signal player_died

func _ready() -> void:
	# Conectar señales
	if not hitbox.is_connected("area_entered", Callable(self, "_on_hitbox_area_entered")):
		hitbox.area_entered.connect(Callable(self, "_on_hitbox_area_entered"))

	var area_salida = get_node_or_null("AreaSalida")
	if area_salida and not area_salida.is_connected("area_entered", Callable(self, "_on_out_of_map_area_entered")):
		area_salida.area_entered.connect(Callable(self, "_on_out_of_map_area_entered"))

	anim_sprite.animation_finished.connect(Callable(self, "_on_animated_sprite_animation_finished"))
	
	# Añadir al grupo de jugadores para facilitar la detección
	add_to_group("player")
	
	# Establecer posición inicial del hitbox
	update_hitbox_position()

func _process(_delta: float) -> void:
	if death:
		return
	handle_input()
	update_animation()

func handle_input() -> void:
	if death or attacking:
		return

	var input_dir = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	).normalized()

	# Actualizar la dirección del jugador y la posición del hitbox
	if input_dir.x > 0:
		facing_right = true
		update_hitbox_position()
	elif input_dir.x < 0:
		facing_right = false
		update_hitbox_position()

	velocity.x = input_dir.x * speed

	if is_on_floor():
		if Input.is_action_just_pressed("Jump Controller"):
			velocity.y = -jump_force

		if Input.is_action_just_pressed("Attack Controller"):
			start_attack()

	velocity.y += gravity
	move_and_slide()

# Función para actualizar la posición del hitbox según la dirección
func update_hitbox_position() -> void:
	if facing_right:
		hitbox.position.x = 0
	else:
		hitbox.position.x = -75

func update_animation() -> void:
	if death:
		if anim_sprite.animation != "death":
			anim_sprite.play("death")
	elif attacking:
		if anim_sprite.animation != "attack":
			anim_sprite.play("attack")
	elif invulnerable and anim_sprite.animation != "hit":
		anim_sprite.play("hit")
	elif not is_on_floor():
		if anim_sprite.animation != "jump":
			anim_sprite.play("jump")
	elif abs(velocity.x) > 0:
		if anim_sprite.animation != "run":
			anim_sprite.play("run")
	else:
		if anim_sprite.animation != "idle":
			anim_sprite.play("idle")

	if velocity.x != 0:
		anim_sprite.scale.x = sign(velocity.x)
		# Actualizar la dirección del jugador basado en la velocidad
		facing_right = velocity.x > 0
		update_hitbox_position()

func start_attack() -> void:
	if attacking:
		return
	attacking = true
	hitbox.monitoring = true
	anim_sprite.play("attack")
	$Hitbox/CollisionShape2D.disabled = false
	
	# Asegurar que el hitbox esté en la posición correcta al atacar
	update_hitbox_position()

func _on_animated_sprite_animation_finished() -> void:
	if anim_sprite.animation == "attack":
		attacking = false
		$Hitbox/CollisionShape2D.disabled = true
		hitbox.monitoring = false
		update_animation()
	elif anim_sprite.animation == "hit":
		update_animation()

# Método para recibir daño
func take_damage(amount: int) -> void:
	if invulnerable or death:
		return
	
	life -= amount
	invulnerable = true
	anim_sprite.play("hit")
	
	# Emitir señal para actualizar UI
	emit_signal("player_hit", life, max_life)

	if life <= 0:
		die()
	else:
		await get_tree().create_timer(invulnerability_time).timeout
		invulnerable = false

func die() -> void:
	death = true
	anim_sprite.play("death")
	# Emitir señal de muerte para que otros nodos puedan reaccionar
	emit_signal("player_died")
	
	# Esperar a que termine la animación de muerte
	await anim_sprite.animation_finished
	# Esperar un segundo adicional
	await get_tree().create_timer(1.0).timeout
	# Cambiar a la escena del menú principal
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")

func _on_hitbox_area_entered(area: Area2D) -> void:
	if attacking:
		# Verificar si el área pertenece a un enemigo y puede recibir daño
		if area.is_in_group("enemy") and area.has_method("take_damage"):
			area.take_damage(attack_damage)
			print("Golpeando área enemiga directamente")
		elif area.get_parent() and area.get_parent().is_in_group("enemy"):
			if area.get_parent().has_method("take_damage"):
				area.get_parent().take_damage(attack_damage)
				print("Golpeando al padre del área enemiga")
			else:
				print("El padre no tiene método take_damage")
		else:
			print("Área golpeada: ", area.name, " - Padre: ", area.get_parent().name if area.get_parent() else "ninguno")

func _on_out_of_map_area_entered(_area: Area2D) -> void:
	take_damage(1)

# Método para restaurar vida
func heal(amount: int) -> void:
	life = min(life + amount, max_life)
	# Emitir señal para actualizar UI
	emit_signal("player_hit", life, max_life)
