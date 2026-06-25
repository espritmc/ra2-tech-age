extends Node
class_name ResourceSystem

## 资源与经济系统
##
## 管理玩家资金和电力。处理采矿收入、建造扣费、电力检查。

# 玩家资源
var credits: float = 10000   # 初始资金
var power_produced: int = 0
var power_consumed: int = 0

# 信号
signal credits_changed(new_amount: float)
signal power_changed(produced: int, consumed: int)


func _ready() -> void:
	print("[ResourceSystem] 资源系统就绪: $%.0f 电力:+%d/-%d" % [credits, power_produced, power_consumed])


## 是否有足够资金
func can_afford(amount: float) -> bool:
	return credits >= amount


## 扣除资金
func spend(amount: float) -> bool:
	if not can_afford(amount):
		return false
	credits -= amount
	credits_changed.emit(credits)
	return true


## 增加资金（采矿收入）
func add_credits(amount: float) -> void:
	credits += amount
	credits_changed.emit(credits)


## 添加电力来源
func add_power_source(amount: int) -> void:
	power_produced += amount
	power_changed.emit(power_produced, power_consumed)


## 移除电力来源
func remove_power_source(amount: int) -> void:
	power_produced = max(0, power_produced - amount)
	power_changed.emit(power_produced, power_consumed)


## 添加电力消耗
func add_power_drain(amount: int) -> void:
	power_consumed += amount
	power_changed.emit(power_produced, power_consumed)


## 移除电力消耗
func remove_power_drain(amount: int) -> void:
	power_consumed = max(0, power_consumed - amount)
	power_changed.emit(power_produced, power_consumed)


## 电力是否充足
func has_sufficient_power() -> bool:
	return power_produced >= power_consumed


## 电力状态文字
func get_power_status() -> String:
	if power_consumed == 0:
		return "闲置"
	if power_produced >= power_consumed:
		return "充足"
	elif power_produced > power_consumed * 0.5:
		return "低电量"
	else:
		return "断电! 生产效率降低50%"


## 获取生产效率倍率
func get_production_efficiency() -> float:
	if not has_sufficient_power() and power_consumed > 0:
		return 0.5
	return 1.0


## 采矿 tick — 由矿场定期调用
func on_mining_tick(amount: float) -> void:
	add_credits(amount)
