extends Control
class_name PoolItem

@onready var name_edit := $NameEdit
@onready var team_edit := $TeamEdit
@onready var weight_edit := $WeightEdit
@onready var count_edit := $CountEdit
@onready var delete_button := $Button

signal deleted

func _ready() -> void:
	delete_button.pressed.connect(func() -> void: deleted.emit())

	weight_edit.text_submitted.connect(update_weight_text)
	weight_edit.focus_exited.connect(func() -> void:
		update_weight_text(weight_edit.text))
	
	count_edit.text_submitted.connect(update_count_text)
	count_edit.focus_exited.connect(func() -> void:
		update_count_text(count_edit.text))

func update_weight_text(new :String) -> void:
	var result := new.to_float()
	result = clamp(result, 0.0, 1.0)
	weight_edit.text = str(result)

func update_count_text(new :String) -> void:
	var result := new.to_int()
	result = max(result, 0)
	count_edit.text = str(result)

func is_valid() -> bool:
	return name_edit.text != "" && team_edit.text != ""

func get_character() -> Character:
	var result := Character.new()
	result.name = name_edit.text
	result.team = team_edit.text
	result.weight = weight_edit.text.to_float()
	result.count = count_edit.text.to_int()
	return result

func load_character(character :Character) -> void:
	name_edit.text = character.name
	team_edit.text = character.team
	weight_edit.text = str(character.weight)
	count_edit.text = str(character.count)
