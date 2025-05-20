extends CharacterBody2D

@export var health : int = 5
@export var score : int = 50
@export var speed : int = 45
@export var gravity : int = 20
@export var damage : int = 2

var direction : int = 1 #Direccion hacia la que se va a mover el nemigo

func _process(_delta):
	if health > 0:
		motion_control()

func motion_control() -> void:
	$AnimatedSprite2D.scale.x = direction
	if not is_on_floor() or is_on_wall():
		direction *= -1


	velocity.x = direction * speed
	velocity.y += gravity
	move_and_slide()
	
func move_to(destino: Vector2) -> void:
	var destiny = destino.x - position.x
	if destiny == 0:
		velocity.x = 0
		return
	var direction = Vector2(destiny, 0).normalized()
	velocity.x = direction.x * speed

func damage_control(damage : int) -> void:
	health -= damage
	
	if health <= 0:
		$Sprite.set_animation("Death")
		
		
		$Collision.set_deferred("disabled", true)
	
		gravity = 0
	
func _on_sprite_animation_finished():
	if $AnimatedSprite2D.animation == "Death":
		queue_free()

func _on_area_hit_body_entered(body):
	if body is Player and health > 0:
		body.damage_ctrl()
