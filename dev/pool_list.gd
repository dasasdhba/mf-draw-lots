extends Control
class_name PoolList

@export_category("PoolList")
@export var left_margin := 4.0
@export var top_margin := 8.0
@export var separator_height := 96.0
@export var item_scene :PackedScene

@onready var new_button :Button = $New

func _ready() -> void:
	new_button.position = Vector2(left_margin, top_margin)
	new_button.pressed.connect(add_item)

func add_item() -> PoolItem:
	var item :PoolItem = item_scene.instantiate()
	var count = get_child_count()
	item.position.x = left_margin
	item.position.y = top_margin + separator_height * (count - 1)
	add_child(item)
	item.deleted.connect(func() -> void:
		item.queue_free()
		sort_items()
	)

	new_button.position = item.position + Vector2(0, separator_height)
	custom_minimum_size.y = new_button.position.y + separator_height
	return item

func sort_items() -> void:
	var i := 0
	for item in get_children():
		if item == new_button or item.is_queued_for_deletion():
			continue
		item.position.x = left_margin
		item.position.y = top_margin + separator_height * i
		i += 1
	new_button.position = Vector2(left_margin, top_margin + separator_height * i)
	custom_minimum_size.y = new_button.position.y + separator_height

func get_characters() -> Array[Character]:
	var characters :Array[Character] = []
	for item in get_children():
		if item == new_button or !item.is_valid():
			continue
		characters.append(item.get_character())
	return characters

func load_characters(characters :Array[Character]) -> void:
	for i in get_children():
		if i == new_button:
			continue
		i.queue_free()
	
	if characters.is_empty():
		new_button.position = Vector2(left_margin, top_margin)
		return

	(func() -> void:
		await get_tree().process_frame
		for character in characters:
			var item := add_item()
			item.load_character(character)
	).call_deferred()

func get_teams() -> Array[String]:
	var teams :Array[String] = []
	for item in get_children():
		if item == new_button or !item.is_valid():
			continue
		var team = item.team_edit.text
		if !teams.has(team):
			teams.append(team)
	return teams

