## 적 엔티티 기본 클래스

class_name Enemy
extends CharacterBody2D

## 적이 사망할 때 발생
signal enemy_defeated(enemy: Enemy, position: Vector2)

@export var enemy_name: String = "Slime"
@export var max_health: int = 30
@export var attack_power: int = 5
@export var defense: int = 2
@export var move_speed: float = 80.0
@export var detection_range: float = 150.0
@export var attack_range: float = 40.0
@export var drop_item_id: String = "gold"
@export var drop_item_chance: float = 0.3
@export var drop_item_scene: PackedScene = preload("res://source/features/entities/items/gold.tscn")
@export var experience_reward: int = 10

@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite: ColorRect = $ColorRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: Node2D = $HealthBar

var player_ref: CharacterBody2D = null
var is_chasing: bool = false
var attack_cooldown: float = 0.0
var attack_cooldown_max: float = 1.0

func _ready() -> void:
	if health_component:
		health_component.max_health = max_health
		health_component.current_health = max_health
		health_component.died.connect(_on_died)
		health_component.health_changed.connect(_on_health_changed)
	
	# HP 바 초기화
	if health_bar:
		health_bar.setup(max_health, max_health)

func _process(delta: float) -> void:
	if not player_ref or health_component.is_dead:
		return
	attack_cooldown = maxi(attack_cooldown - delta, 0.0)
	var distance: float = global_position.distance_to(player_ref.global_position)
	if distance <= attack_range and attack_cooldown <= 0.0:
		_perform_attack()
	elif distance <= detection_range:
		_chase_player()
	else:
		is_chasing = false
		velocity = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _chase_player() -> void:
	if not player_ref:
		return
	is_chasing = true
	var direction: Vector2 = (player_ref.global_position - global_position).normalized()
	velocity = direction * move_speed
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("walk"):
		sprite.play("walk")
	# 방향에 따라 스프라이트 뒤집기
	if direction.x != 0:
		sprite.flip_h = direction.x < 0

func _perform_attack() -> void:
	attack_cooldown = attack_cooldown_max
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
	EventBus.enemy_spawned.emit(self)

func take_damage(amount: int) -> bool:
	if health_component:
		var died: bool = health_component.take_damage(amount)
		EventBus.enemy_died.emit(self, global_position)
		return died
	return false

func _on_died() -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
	else:
		_defeat()

func _defeat() -> void:
	EventBus.enemy_died.emit(self, global_position)
	EventBus.experience_gained.emit(experience_reward)
	enemy_defeated.emit(self, global_position)
	
	# 아이템 드랍
	_drop_item()
	
	queue_free()

func _drop_item() -> void:
	"""아이템 드랍"""
	if randf() > drop_item_chance:
		return
	
	if not drop_item_scene:
		return
	
	var item: Node = drop_item_scene.instantiate()
	item.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	get_tree().current_scene.add_child(item)

func _on_health_changed(current: int, maximum: int) -> void:
	# HP 바 업데이트
	if health_bar:
		health_bar.set_health(current)
