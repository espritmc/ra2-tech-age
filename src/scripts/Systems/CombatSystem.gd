extends Node2D
class_name CombatSystem

## 战斗系统
##
## 处理伤害计算、护甲类型克制、范围伤害、死亡处理。
## 参考红警2的伤害模型：穿甲弹 vs 轻甲/中甲/重甲。

enum ArmorType {
	NONE,       # 无甲（建筑、平民）
	LIGHT,      # 轻甲（步兵）
	MEDIUM,     # 中甲（轻型载具）
	HEAVY,      # 重甲（主战坦克）
	STRUCTURE,  # 建筑装甲
}

enum DamageType {
	BULLET,       # 子弹 — 对步兵优
	ARMOR_PIERCING,  # 穿甲弹 — 对载具优
	EXPLOSIVE,    # 爆炸 — 通用
	LASER,        # 激光 — 无视部分护甲
	EMP,          # EMP — 瘫痪，无杀伤
}


## 伤害倍率表 [DamageType][ArmorType]
const DAMAGE_MULTIPLIER = {
	DamageType.BULLET: {
		ArmorType.NONE: 1.0,
		ArmorType.LIGHT: 1.0,
		ArmorType.MEDIUM: 0.3,
		ArmorType.HEAVY: 0.1,
		ArmorType.STRUCTURE: 0.1,
	},
	DamageType.ARMOR_PIERCING: {
		ArmorType.NONE: 0.5,
		ArmorType.LIGHT: 0.5,
		ArmorType.MEDIUM: 1.0,
		ArmorType.HEAVY: 1.0,
		ArmorType.STRUCTURE: 0.5,
	},
	DamageType.EXPLOSIVE: {
		ArmorType.NONE: 1.0,
		ArmorType.LIGHT: 1.0,
		ArmorType.MEDIUM: 0.8,
		ArmorType.HEAVY: 0.5,
		ArmorType.STRUCTURE: 1.0,
	},
	DamageType.LASER: {
		ArmorType.NONE: 2.0,
		ArmorType.LIGHT: 1.5,
		ArmorType.MEDIUM: 1.0,
		ArmorType.HEAVY: 0.8,
		ArmorType.STRUCTURE: 1.2,
	},
	DamageType.EMP: {
		ArmorType.NONE: 0.0,
		ArmorType.LIGHT: 0.0,
		ArmorType.MEDIUM: 0.0,
		ArmorType.HEAVY: 0.0,
		ArmorType.STRUCTURE: 0.0,
	},
}


## 计算实际伤害
func calculate_damage(base_damage: float, damage_type: DamageType, armor_type: ArmorType) -> float:
	var multiplier = DAMAGE_MULTIPLIER[damage_type][armor_type]
	return base_damage * multiplier


## 范围伤害
func deal_area_damage(center: Vector2, radius: float, base_damage: float, 
					  damage_type: DamageType, targets: Array) -> void:
	for unit in targets:
		if not is_instance_valid(unit) or not unit.is_alive:
			continue
		var distance = center.distance_to(unit.global_position)
		if distance > radius:
			continue
		
		# 距离衰减
		var falloff = 1.0 - (distance / radius) * 0.7
		var damage = calculate_damage(base_damage * falloff, damage_type, ArmorType.MEDIUM)
		unit.take_damage(damage)
