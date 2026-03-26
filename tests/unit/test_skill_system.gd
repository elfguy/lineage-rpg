extends GutTest

var skill_system: Node
var test_skill: SkillResource

func before_each() -> void:
	skill_system = preload("res://source/features/player/skill_system.gd").new()
	add_child_autofree(skill_system)

	test_skill = SkillResource.new()
	test_skill.skill_id = "fireball"
	test_skill.skill_name = "Fireball"
	test_skill.mp_cost = 10
	test_skill.cooldown = 2.0
	test_skill.required_level = 1
	test_skill.max_level = 5
	test_skill.base_damage = 20
	test_skill.damage_per_level = 10
	skill_system.register_skill(test_skill)

func test_learn_skill() -> void:
	var result: bool = skill_system.learn_skill("fireball")
	assert_true(result, "Should learn skill")
	assert_true(skill_system.learned_skills.has("fireball"))

func test_learn_skill_twice_fails() -> void:
	skill_system.learn_skill("fireball")
	var result: bool = skill_system.learn_skill("fireball")
	assert_false(result, "Should not learn same skill twice")

func test_use_skill() -> void:
	skill_system.learn_skill("fireball")
	GameState.player_data["mp"] = 50
	var result: bool = skill_system.use_skill("fireball")
	assert_true(result, "Should use skill")
	assert_eq(GameState.player_data["mp"], 40, "MP should decrease by cost")

func test_use_skill_no_mp() -> void:
	skill_system.learn_skill("fireball")
	GameState.player_data["mp"] = 5
	var result: bool = skill_system.use_skill("fireball")
	assert_false(result, "Should fail without enough MP")

func test_skill_cooldown() -> void:
	skill_system.learn_skill("fireball")
	GameState.player_data["mp"] = 50
	skill_system.use_skill("fireball")
	var slot: SkillSlot = skill_system.learned_skills.get("fireball")
	assert_true(slot.is_on_cooldown(), "Should be on cooldown")
	skill_system.use_skill("fireball")
	# 쿨다운 중이면 사용 불가 — MP는 그대로
	assert_eq(GameState.player_data["mp"], 40, "MP should not decrease during cooldown")

func test_skill_level_up() -> void:
	skill_system.learn_skill("fireball")
	var result: bool = skill_system.level_up_skill("fireball")
	assert_true(result, "Should level up skill")
	var slot: SkillSlot = skill_system.learned_skills.get("fireball")
	assert_eq(slot.current_level, 2, "Level should be 2")

func test_skill_max_level() -> void:
	skill_system.learn_skill("fireball")
	for _i: int in range(4):
		skill_system.level_up_skill("fireball")
	var result: bool = skill_system.level_up_skill("fireball")
	assert_false(result, "Should not exceed max level")

func test_skill_level_requirement() -> void:
	var advanced_skill: SkillResource = SkillResource.new()
	advanced_skill.skill_id = "meteor"
	advanced_skill.skill_name = "Meteor"
	advanced_skill.required_level = 10
	skill_system.register_skill(advanced_skill)
	assert_false(skill_system.can_learn_skill("meteor"), "Should not learn at level 1")
	GameState.player_data["level"] = 10
	assert_true(skill_system.can_learn_skill("meteor"), "Should learn at level 10")
	GameState.player_data["level"] = 1

func test_skill_damage_scaling() -> void:
	assert_eq(test_skill.get_damage_at(1), 20, "Level 1 damage = 20")
	assert_eq(test_skill.get_damage_at(3), 40, "Level 3 damage = 40")
	assert_eq(test_skill.get_damage_at(5), 60, "Level 5 damage = 60")

func test_skill_prerequisite() -> void:
	var advanced: SkillResource = SkillResource.new()
	advanced.skill_id = "fireball_2"
	advanced.skill_name = "Fireball II"
	advanced.prerequisite_skills = ["fireball"]
	skill_system.register_skill(advanced)
	assert_false(skill_system.can_learn_skill("fireball_2"), "Should require fireball first")
	skill_system.learn_skill("fireball")
	assert_true(skill_system.can_learn_skill("fireball_2"), "Should learn after prerequisite")
