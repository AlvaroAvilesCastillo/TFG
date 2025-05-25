extends CharacterBody2D
class_name StandardEnemy

@export_category("Movement")
@export var speed: int = 40
@export var gravity: int = 400

@export_category("Combat")
@export var max_health: int = 2 
@export var damage: int = 1
@export var attack_cooldown: float = 1.0
@export var attack_distance: float = 100.0  # Distancia a la que el enemigo atacará al jugador

@onready var animation: AnimatedSprite2D = $Animaciones/AnimatedSprite2D
@onready var hit_area: Area2D = $AreaHIT
@onready var vision_area: Area2D = $AreaVision

var direction: int = -1
var is_attacking: bool = false
var is_pursuing: bool = false
var is_hit: bool = false
var player_ref: Node2D = null
var health: int = max_health
var can_attack: bool = true

func _ready() -> void:
	# Conectar señales
	hit_area.body_entered.connect(_on_hit_area_body_entered)
	hit_area.body_exited.connect(_on_hit_area_body_exited)
	vision_area.body_entered.connect(_on_vision_area_body_entered)
	vision_area.body_exited.connect(_on_vision_area_body_exited)
	animation.animation_finished.connect(_on_animation_finished)
	
	# Añadir al grupo de enemigos para facilitar la detección
	add_to_group("enemy")
	
	# Establecer posición inicial del hitbox
	update_hitbox_position()

func _physics_process(delta: float) -> void:
	if is_hit:
		velocity.x = 0
	elif is_attacking:
		velocity.x = 0
		if animation.animation != "attack":
			animation.play("attack")
	elif is_pursuing and player_ref:
		pursue_player()
		# Verificar si el jugador está a distancia de ataque
		check_attack_distance()
	else:
		patrol()

	# Aplicar gravedad
	velocity.y += gravity * delta
	move_and_slide()

# Función para actualizar la posición del hitbox según la dirección
func update_hitbox_position() -> void:
	if direction > 0:  # Mirando a la derecha
		hit_area.position.x = 0
	else:  # Mirando a la izquierda
		hit_area.position.x = -50

func patrol() -> void:
	animation.scale.x = direction
	velocity.x = direction * speed
	
	if animation.animation != "walk":
		animation.play("walk")
	
	# Cambiar dirección al chocar con paredes o llegar al borde
	if is_on_wall() or not $RayCast2D.is_colliding():
		# Añadir un pequeño desplazamiento para evitar quedarse atascado
		position.x += direction * -5
		
		# Cambiar dirección
		direction *= -1
		animation.scale.x = direction
		
		# Actualizar posición del hitbox al cambiar dirección
		update_hitbox_position()
		
		# Imprimir mensaje de depuración
		print("Enemigo cambiando dirección")
	
		# Actualizar posición del hitbox al cambiar dirección
		update_hitbox_position()

func _on_hit_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and can_attack:
		is_attacking = true
		velocity.x = 0
		animation.play("attack")
		
		# Asegurar que el hitbox esté en la posición correcta al atacar
		update_hitbox_position()
		
		# Esperar hasta los últimos frames para aplicar daño
		await get_tree().create_timer(0.5).timeout  # Ajustar este tiempo según la duración de la animación
		
		# Verificar que el jugador sigue en el área y que seguimos atacando
		if is_attacking and body.is_in_group("player") and body.has_method("take_damage"):
			print("Enemigo atacando al jugador con ", damage, " de daño")
			body.take_damage(damage)
		
		# Iniciar cooldown de ataque
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func _on_hit_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		is_attacking = false

func _on_vision_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		is_pursuing = true
		player_ref = body

func _on_vision_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		is_pursuing = false
		player_ref = null

func take_damage(amount: int) -> void:
	if is_hit:
		return  # Evita recibir daño múltiple mientras está en animación

	health -= amount
	is_hit = true
	is_attacking = false  # Cancela ataque si estaba atacando
	velocity.x = 0
	animation.play("hit")

	if health <= 0:
		die()

func die() -> void:
	# Desactivar colisiones y movimiento
	set_physics_process(false)
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	hit_area.set_deferred("monitoring", false)
	hit_area.set_deferred("monitorable", false)
	vision_area.set_deferred("monitoring", false)
	vision_area.set_deferred("monitorable", false)
	
	# Reproducir animación de muerte
	if animation.sprite_frames.has_animation("death"):
		print("Reproduciendo animación de muerte")
		animation.play("death")
		await animation.animation_finished
		print("Animación de muerte terminada")
	
	# Eliminar el enemigo después de la animación
	queue_free()

func _on_animation_finished() -> void:
	if animation.animation == "hit":
		is_hit = false
		if is_pursuing and player_ref:
			pursue_player()
		else:
			patrol()
	elif animation.animation == "attack":
		is_attacking = false
		if is_pursuing and player_ref:
			pursue_player()
		else:
			patrol()

func pursue_player() -> void:
	if not player_ref:
		return

	var to_player = player_ref.global_position.x - global_position.x
	direction = sign(to_player)
	animation.scale.x = direction
	velocity.x = direction * speed
	
	# Actualizar posición del hitbox según la dirección al jugador
	update_hitbox_position()

# Nueva función para verificar la distancia al jugador y atacar si está lo suficientemente cerca
func check_attack_distance() -> void:
	if not player_ref or not can_attack:
		return
		
	var distance = abs(player_ref.global_position.x - global_position.x)
	if distance <= attack_distance:
		is_attacking = true
		velocity.x = 0
		animation.play("attack")
		
		# Asegurar que el hitbox esté en la posición correcta al atacar
		update_hitbox_position()
		
		# Esperar hasta los últimos frames para aplicar daño
		await get_tree().create_timer(0.5).timeout  # Ajustar este tiempo según la duración de la animación
		
		# Verificar que el jugador sigue cerca y que seguimos atacando
		if is_attacking and player_ref and player_ref.has_method("take_damage"):
			print("Enemigo atacando al jugador con ", damage, " de daño (por distancia)")
			player_ref.take_damage(damage)
		
		# Iniciar cooldown de ataque
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true
