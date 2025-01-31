extends Control

@onready var player_label := $Label
@onready var player_list := $PlayerList
@onready var result_list := $Result
@onready var ratio :Ratio = $Ratio
@onready var pool :PoolList = $PoolSetting/ScrollContainer/Control
@onready var start_button := $Start
@onready var copy_button := $Copy

const PLAYER_HINT :String = "玩家列表"

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_button.pressed.connect(start)
	copy_button.pressed.connect(copy)

func _process(_delta: float) -> void:
	var count = get_player_count()
	player_label.text = PLAYER_HINT + " (" + str(count) + ")"

func get_player_list() -> Array[String]:
	var list :Array[String] = []
	for i in range(player_list.get_line_count()):
		var text = player_list.get_line(i)
		if text!= "":
			list.append(text)
	return list

func get_player_count() -> int:
	var count := 0
	for i in range(player_list.get_line_count()):
		var text = player_list.get_line(i)
		if text!= "":
			count += 1
	return count

func start() -> void:
	result_list.text = ""
	var ratios := ratio.get_ratio()
	var players := get_player_list()

	var sum := 0
	for i in range(ratios.size()):
		sum += ratios[i]
	if players.size() != sum:
		result_list.text = "玩家数量与阵营比例不匹配！"
		return

	var teams := pool.get_teams()
	var charas := pool.get_characters()

	var result :Array[String] = []
	for i in range(teams.size()):
		var count = ratios[i]
		if count <= 0:
			continue
		
		var team = teams[i]
		var members := get_team_members(charas, team, count)
		if members.size() == 0:
			result_list.text = "身份池数量不足！"
			return

		sort_arr(members)
		for j in range(count):
			var member := pick_member(members)
			result.append(member.name)
	
	result.shuffle()
	for i in range(players.size()):
		var p_name = players[i]
		result_list.text += get_circle_count(i+1) + p_name + "：" + result[i] + "\n"

func copy() -> void:
	var t = result_list.text
	if t == "":
		return
	DisplayServer.clipboard_set(t)

static func get_team_members(arr :Array[Character], team :String, count :int) -> Array[Character]:
	arr = filter_team(arr, team)
	if arr.size() < count:
		arr = []
		return arr
	
	return arr

static func filter_team(arr :Array[Character], team :String) -> Array[Character]:
	var result :Array[Character] = []
	for c in arr:
		if c.team != team or c.count <= 0 or c.weight <= 0.0:
			continue
		for i in range(c.count):
			result.append(c)
	return result

static func sort_arr(arr :Array[Character]) -> void:
	arr.sort_custom(func(a ,b) : return a.weight >= b.weight)

static func pick_member(arr :Array[Character]) -> Character:
	if (arr[0].weight >= 1.0):
		return arr.pop_front()
	
	var sum := 0.0
	for c in arr:
		sum += c.weight
	var r := randf() * sum
	var s := 0.0
	for i in range(arr.size()):
		var c := arr[i]
		s += c.weight
		if s >= r:
			arr.remove_at(i)
			return c
	return arr.pop_back()

const CIRCLE_STR := "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿"

static func get_circle_count(count :int) -> String:
	if count <= 0 or count > 50:
		return str(count)
	return CIRCLE_STR[count-1]