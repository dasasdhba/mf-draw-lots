extends Control

@onready var config_name := $LineEdit
@onready var config_menu :PopupMenu = $MenuButton.get_popup()
@onready var config_load := $Load
@onready var config_save := $Save
@onready var config_delete := $Delete
@onready var pool := $ScrollContainer/Control

const INI_NAME := "config.ini"

static func get_config_path() -> String:
	var path := OS.get_executable_path().get_base_dir()
	return path + "/" + INI_NAME

func _ready() -> void:
	load_config_list()
	load_config()

	config_menu.index_pressed.connect(func(i) -> void:
		var t = config_menu.get_item_text(i)
		config_name.text = t
	)
	config_load.pressed.connect(load_config)
	config_save.pressed.connect(save_config)
	config_delete.pressed.connect(delete_config)

func load_config_list() -> void:
	config_menu.clear()
	config_menu.add_item("default")

	var config := ConfigFile.new()
	if config.load(get_config_path()) != OK:
		return
	
	for s in config.get_sections():
		if s != "default":
			config_menu.add_item(s)

func load_config() -> void:
	var config := ConfigFile.new()
	if config.load(get_config_path()) != OK:
		return
	
	var c_name = config_name.text
	if c_name == "":
		c_name = "default"
	
	if not config.has_section(c_name):
		var arr :Array[Character] = []
		pool.load_characters(arr)
		return
	
	var charas :Array[Character] = config.get_value(c_name, "charas", [])
	pool.load_characters(charas)

func save_config() -> void:
	var config := ConfigFile.new()
	config.load(get_config_path())

	var c_name = config_name.text
	if c_name == "":
		c_name = "default"
	
	config.set_value(c_name, "charas", pool.get_characters())
	config.save(get_config_path())
	load_config_list()

func delete_config() -> void:
	var config := ConfigFile.new()
	if config.load(get_config_path()) != OK:
		return
	
	var c_name = config_name.text
	if c_name == "":
		c_name = "default"
	
	if not config.has_section(c_name):
		return
	config.erase_section(c_name)
	config.save(get_config_path())
	load_config_list()
