extends GutTest

func test_damage_calculator_basic() -> void:
	var damage: int = DamageCalculator.calculate(20, 5)
	assert_eq(damage, 15, "20 attack - 5 defense = 15 damage")

func test_damage_calculator_minimum_one() -> void:
	var damage: int = DamageCalculator.calculate(3, 10)
	assert_eq(damage, 1, "Minimum damage should be 1")

func test_damage_calculator_zero_defense() -> void:
	var damage: int = DamageCalculator.calculate(15, 0)
	assert_eq(damage, 15, "No defense = full attack damage")

func test_damage_calculator_equal() -> void:
	var damage: int = DamageCalculator.calculate(10, 10)
	assert_eq(damage, 1, "Equal attack/defense = minimum 1")

func test_critical_calculation() -> void:
	var result: Dictionary = DamageCalculator.calculate_critical(20, 5, 0.0, 1.5)
	assert_eq(result.get("damage"), 15, "0% crit rate should not crit")
	assert_eq(result.get("is_critical"), false, "Should not be critical")

func test_health_component_init() -> void:
	var health: HealthComponent = HealthComponent.new()
	health.max_health = 100
	health.current_health = 100
	add_child_autofree(health)
	assert_eq(health.current_health, 100, "Should start with 100 HP")
	assert_eq(health.get_health_percent(), 1.0, "Should be 100%")

func test_health_component_take_damage() -> void:
	var health: HealthComponent = HealthComponent.new()
	health.max_health = 100
	health.current_health = 100
	add_child_autofree(health)
	var died: bool = health.take_damage(30)
	assert_eq(health.current_health, 70, "Should have 70 HP left")
	assert_false(died, "Should not be dead")

func test_health_component_death() -> void:
	var health: HealthComponent = HealthComponent.new()
	health.max_health = 100
	health.current_health = 100
	add_child_autofree(health)
	var died: bool = health.take_damage(100)
	assert_eq(health.current_health, 0, "Should have 0 HP")
	assert_true(died, "Should be dead")
	assert_true(health.is_dead, "is_dead should be true")

func test_health_component_heal() -> void:
	var health: HealthComponent = HealthComponent.new()
	health.max_health = 100
	health.current_health = 50
	add_child_autofree(health)
	health.heal(30)
	assert_eq(health.current_health, 80, "Should heal to 80")

func test_health_component_no_overheal() -> void:
	var health: HealthComponent = HealthComponent.new()
	health.max_health = 100
	health.current_health = 80
	add_child_autofree(health)
	health.heal(50)
	assert_eq(health.current_health, 100, "Should not exceed max HP")

func test_health_component_no_heal_when_dead() -> void:
	var health: HealthComponent = HealthComponent.new()
	health.max_health = 100
	health.current_health = 100
	add_child_autofree(health)
	health.take_damage(100)
	health.heal(50)
	assert_eq(health.current_health, 0, "Should not heal when dead")
