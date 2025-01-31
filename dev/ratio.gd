extends Control
class_name Ratio

@export_category("Ratio")
@export var top_margin := 36.0
@export var separator_width := 96.0

@onready var pool :PoolList = get_node("../PoolSetting/ScrollContainer/Control")
@onready var label := $Label

const HINT_STR := "阵营比例："

func create_ratio_edit() ->LineEdit:
	var edit := LineEdit.new()
	edit.text = "0"
	edit.text_submitted.connect(update_count_text.bind(edit))
	edit.focus_exited.connect(func() -> void:
		update_count_text(edit, edit.text)
	)
	return edit

func update_count_text(edit: LineEdit, new :String) -> void:
	var result := new.to_int()
	result = max(result, 0)
	edit.text = str(result)

var team_count := 0

func update_ratio() ->void:
	var team := pool.get_teams()
	label.text = HINT_STR
	var s = team.size()
	for i in range(s):
		label.text += team[i]
		if i < s - 1:
			label.text += "："

	if team_count == s:
		return

	for c in get_children():
		if c is LineEdit:
			c.queue_free()

	for i in range(s):
		var edit := create_ratio_edit()
		edit.position = Vector2(separator_width * i, top_margin)
		add_child(edit)

	team_count = s

func get_ratio() -> Array[int]:
	var result :Array[int]= []
	for c in get_children():
		if c is LineEdit:
			result.append(c.text.to_int())
	return result

func _process(_delta: float) -> void:
	update_ratio()