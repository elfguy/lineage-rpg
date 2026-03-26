## 소비 아이템 Resource

class_name ConsumableResource
extends ItemResource

enum EffectType {
	HEAL_HP,
	HEAL_MP,
	BUFF_ATTACK,
	BUFF_DEFENSE,
}

@export var effect_type: EffectType = EffectType.HEAL_HP
@export var effect_value: int = 0
