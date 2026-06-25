extends Node
class_name NetworkManager

## 网络管理器
##
## 局域网联机：房间创建/加入、命令同步。
## 使用 Godot 内置 ENet (UDP)。

signal connected()
signal disconnected()
signal player_joined(player_id: int, faction: String)
signal player_left(player_id: int)
signal game_started()

enum NetMode {
	OFFLINE,
	HOST,
	CLIENT,
}

var mode: NetMode = NetMode.OFFLINE
var peer: ENetMultiplayerPeer = null
var port: int = 27015
var max_players: int = 4
var my_player_id: int = 1

# 玩家信息
var players: Dictionary = {}  # player_id -> {faction, name}


func _ready() -> void:
	print("[NetworkManager] 网络管理器就绪 — 模式: %s" % _mode_string())


func _mode_string() -> String:
	match mode:
		NetMode.OFFLINE: return "离线"
		NetMode.HOST: return "主机"
		NetMode.CLIENT: return "客户端"
	return "?"


## 创建房间（主机）
func host_game() -> void:
	print("[NetworkManager] 创建房间...")
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_players)
	
	if error != OK:
		print("[NetworkManager] ❌ 创建服务器失败: %d" % error)
		return
	
	multiplayer.multiplayer_peer = peer
	mode = NetMode.HOST
	my_player_id = multiplayer.get_unique_id()
	players[my_player_id] = {"faction": "allied", "name": "玩家1"}
	
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)
	
	connected.emit()
	print("[NetworkManager] ✅ 房间已创建 — 端口: %d" % port)


## 加入房间（客户端）
func join_game(address: String) -> void:
	print("[NetworkManager] 加入房间: %s:%d" % [address, port])
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	
	if error != OK:
		print("[NetworkManager] ❌ 连接失败: %d" % error)
		return
	
	multiplayer.multiplayer_peer = peer
	mode = NetMode.CLIENT
	my_player_id = multiplayer.get_unique_id()
	
	peer.connected_to_server.connect(_on_connected_to_server)
	peer.connection_failed.connect(_on_connection_failed)
	peer.server_disconnected.connect(_on_server_disconnected)
	
	print("[NetworkManager] 正在连接...")


func _on_peer_connected(id: int) -> void:
	print("[NetworkManager] 玩家加入: %d" % id)
	players[id] = {"faction": "soviet", "name": "玩家%d" % players.size()}
	player_joined.emit(id, "soviet")


func _on_peer_disconnected(id: int) -> void:
	print("[NetworkManager] 玩家离开: %d" % id)
	players.erase(id)
	player_left.emit(id)


func _on_connected_to_server() -> void:
	print("[NetworkManager] ✅ 已连接到主机")
	connected.emit()


func _on_connection_failed() -> void:
	print("[NetworkManager] ❌ 连接失败")
	mode = NetMode.OFFLINE


func _on_server_disconnected() -> void:
	print("[NetworkManager] ⚠️ 与主机断开连接")
	mode = NetMode.OFFLINE
	disconnected.emit()


## 开始游戏（主机可调用）
func start_game() -> void:
	if mode != NetMode.HOST:
		return
	game_started.rpc()


## 发送聊天消息
@rpc("any_peer", "call_remote", "reliable")
func send_chat(message: String) -> void:
	print("[聊天] 玩家%d: %s" % [multiplayer.get_remote_sender_id(), message])


## 断开连接
func disconnect() -> void:
	if peer:
		peer.close()
		peer = null
	mode = NetMode.OFFLINE
	players.clear()
	disconnected.emit()
	print("[NetworkManager] 已断开")
