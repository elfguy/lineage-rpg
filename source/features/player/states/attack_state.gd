extends State

var player: CharacterBody2D
var attack_duration: float = 0.4
var attack_timer: float = 0.0
var attack_range: float = 40.0
var attack_damage: int = 10
var has_dealt_damage: bool = false

func _ready() -> void:
	player = get_parent().get_parent()

func enter(_data: Dictionary) -> void:
	attack_timer = 0.0
	has_dealt_damage = false
	player.velocity = Vector2.ZERO
	# 공격 애니메이션이 있으면 재생
	# ColorRect라 애니메이션 없음

func update(delta: float) -> void:
	attack_timer += delta

	# 공격 타이밍에 데미지 적용
	if attack_timer >= 0.15 and not has_dealt_damage:
		_deal_attack_damage()
		has_dealt_damage = true

	if attack_timer >= attack_duration:
		state_machine.transition_to("idle")

func _deal_attack_damage() -> void:
	"""전방의 적에게 데미지 적용"""
	var space_state: PhysicsDirectSpaceState2D = player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()

	# 공격 범위 설정
	var attack_pos: Vector2 = player.global_position
	match player.facing:
		"up":
			attack_pos.y -= attack_range
		"down":
			attack_pos.y += attack_range
		"left":
			attack_pos.x -= attack_range
		"right":
			attack_pos.x += attack_range

	# 적 감지
	var enemies: Array[Node2D] = []
	for body in player.get_tree().get_nodes_in_group("enemy"):
		if body is CharacterBody2D:
			var dist: float = player.global_position.distance_to(body.global_position)
			if dist <= attack_range * 1.5:
				enemies.append(body)

	# 데미지 적용
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(attack_damage)
			EventBus.player_attacked.emit(enemy, attack_damage)

