## 적 스포너
## 정해진 위치에 적을 생성합니다.

class_name EnemySpawner
extends Node2D

@export var enemy_scene: PackedScene = null
@export var spawn_interval: float = 10.0
@export var max_spawned: int = 5
@export var spawn_radius: float = 200.0

var spawned_enemies: Array[Enemy] = []
var spawn_timer: float = 0.0

func _process(delta: float) -> void:
	if enemy_scene == null:
		return
	_cleanup_dead_enemies()
	if spawned_enemies.size() >= max_spawned:
		return
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_enemy()

func _spawn_enemy() -> void:
	if enemy_scene == null:
		return
	var instance: Enemy = enemy_scene.instantiate() as Enemy
	if instance == null:
		return
	var angle: float = randf() * TAU
	var distance: float = randf() * spawn_radius
	var offset: Vector2 = Vector2(cos(angle), sin(angle)) * distance
	instance.global_position = global_position + offset
	instance.enemy_defeated.connect(_on_enemy_defeated)
	add_child(instance)
	spawned_enemies.append(instance)

func _cleanup_dead_enemies() -> void:
	var alive: Array[Enemy] = []
	for enemy: Enemy in spawned_enemies:
		if is_instance_valid(enemy):
			alive.append(enemy)
	spawned_enemies = alive

func _on_enemy_defeated(_enemy: Enemy, _position: Vector2) -> void:
	_cleanup_dead_enemies()
