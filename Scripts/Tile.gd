extends Node2D

var id:int

onready var game = get_node("/root/Game")
onready var planet = get_parent()
onready var p_i = get_parent().p_i
onready var view = planet.get_parent()
onready var tile = game.tile_data[id]
onready var building_info = $BuildingInformation
onready var time_left = $TimeLeft
onready var time_left_bar = $TimeLeft/Bar
onready var time_left_str = $TimeLeft/TimeString
onready var current_bar = $BuildingInformation/CurrentBar
onready var capacity_bar = $BuildingInformation/CapacityBar
onready var rsrc_stocked = $BuildingInformation/ResourceStocked

func _ready():
	var tile_texture = load("res://Graphics/Tiles/" + String(p_i["type"]) + ".jpg")
	$Texture.texture = tile_texture
	if tile.is_constructing:
		$TimeLeft.visible = true
	display_bldg(tile.bldg_str, 1)
	display_icon()
	if tile.depth > 0:
		$Hole.visible = true
	update_lv_visibility()

func update_lv_visibility():
	if tile.bldg_str != "":
		$HBoxContainer/Label.visible = true
		$HBoxContainer/Label.text = String(tile.bldg_info.path_1)
		if tile.bldg_info.has("path_2"):
			$HBoxContainer/Label2.visible = true
			$HBoxContainer/Label2.text = String(tile.bldg_info.path_2)
		if tile.bldg_info.has("path_3"):
			$HBoxContainer/Label3.visible = true
			$HBoxContainer/Label3.text = String(tile.bldg_info.path_3)

func _process(_delta):
	if tile.bldg_str != "":
		building_info.visible = true
		var constr_progress = (OS.get_system_time_msecs() - tile.construction_date) / float(tile.construction_length)
		time_left_bar.rect_scale.x = constr_progress
		time_left_str.text = Helper.time_to_str(tile.construction_length - OS.get_system_time_msecs() + tile.construction_date)
		if constr_progress < 1:
			time_left.visible = true
		else:
			if tile.is_constructing:
				tile.is_constructing = false
				construction_finished()
			time_left.visible = false
			match tile.bldg_str:
				"ME", "PP":
					#Number of seconds needed per mineral
					var prod = 1 / tile.bldg_info["path_1_value"]
					var cap = tile.bldg_info["path_2_value"]
					var stored = tile.bldg_info["stored"]
					var c_d = tile.bldg_info["collect_date"]
					var c_t = OS.get_system_time_msecs()
					if stored < cap:
						current_bar.rect_scale.x = min((c_t - c_d) / (prod * 1000), 1)
						capacity_bar.rect_scale.x = min(stored / float(cap), 1)
						if c_t - c_d > prod * 1000:
							tile.bldg_info["stored"] += 1
							tile.bldg_info["collect_date"] += prod * 1000
					else:
						current_bar.rect_scale.x = 0
						capacity_bar.rect_scale.x = 1
					rsrc_stocked.text = String(stored)
	else:
		building_info.visible = false

func construction_finished():
	update_lv_visibility()

func _on_Button_button_over():
	#Make sure there's nothing on the tile before putting graphics
	if tile.bldg_str == "":
		game.bldg_blueprints.append(id)
		display_bldg(planet.bldg_to_construct, 0.5)
	else:
		var tooltip:String = ""
		var icons = []
		match tile.bldg_str:
			"ME":
				tooltip = "Extracts " + (Data.path_1[tile.bldg_str].desc + "\n" + Data.path_2[tile.bldg_str].desc) % [tile.bldg_info.path_1_value, tile.bldg_info.path_2_value]
				#tooltip = "Produces @i%s per second\nStores @i%s" % [tile.bldg_info.production, tile.bldg_info.capacity]
				icons = [load("res://Graphics/Icons/Minerals.png"), load("res://Graphics/Icons/Minerals.png")]
			"PP":
				tooltip = "Generates " + (Data.path_1[tile.bldg_str].desc + "\n" + Data.path_2[tile.bldg_str].desc) % [tile.bldg_info.path_1_value, tile.bldg_info.path_2_value]
				#tooltip = "Produces @i%s per second\nStores @i%s" % [tile.bldg_info.production, tile.bldg_info.capacity]
				icons = [load("res://Graphics/Icons/Energy.png"), load("res://Graphics/Icons/Energy.png")]
		tooltip += "\n" + tr("PRESS_F_TO_UPGRADE") + "\n" + tr("PRESS_Q_TO_DUPLICATE")
		game.show_adv_tooltip(tooltip, icons)
	planet.tile_over = id

func _on_Button_button_out():
	if tile.bldg_str == "":
		game.bldg_blueprints.erase(id)
		$Building.texture = null
	game.hide_adv_tooltip()

func _on_Button_button_pressed():
	#Checks whether we're dragging or not. We don't want the click event to happen while the player is dragging
	if not view.dragged:
		#Checks if tile is empty
		if tile.bldg_str == "":
			#If we're trying to construct something
			if planet.bldg_to_construct != "":
				if game.check_enough(planet.constr_costs):
					game.deduct_resources(planet.constr_costs)
					tile.bldg_str = planet.bldg_to_construct
					_on_Button_button_out()
					display_bldg(tile.bldg_str, 1)
					display_icon()
					if not game.show.minerals and tile.bldg_str == "ME":
						game.show.minerals = true
					$TimeLeft.visible = true
					tile.is_constructing = true
					tile.construction_date = OS.get_system_time_msecs()
					tile.construction_length = planet.constr_costs["time"] * 1000
					add_bldg_info()
				else:
					game.popup("Not enough resources", 1)
			elif game.about_to_mine:
				game.get_node("Control/BottomInfo").visible = false
				game.c_t = id
				game.switch_view("mining")
		else:
			match tile.bldg_str:
				"ME":
					var mineral_space_available = game.mineral_capacity - game.minerals
					var stored = tile.bldg_info["stored"]
					if mineral_space_available >= stored:
						tile.bldg_info["stored"] = 0
						game.minerals += stored
					else:
						game.minerals = game.mineral_capacity
						tile.bldg_info["stored"] -= mineral_space_available
					if stored == tile.bldg_info["path_2_value"]:
						tile.bldg_info["collect_date"] = OS.get_system_time_msecs()
				"PP":
					var stored = tile.bldg_info["stored"]
					if stored == tile.bldg_info["path_2_value"]:
						tile.bldg_info["collect_date"] = OS.get_system_time_msecs()
					game.energy += stored
					tile.bldg_info["stored"] = 0
	view.dragged = false

func display_bldg(bldg_str:String, a:float):
	if bldg_str != "":
		var bldg_image = load("res://Graphics/Buildings/" + bldg_str + ".png")
		$Building.texture = bldg_image
		$Building.modulate.a = a

func display_icon():
	if tile.bldg_str != "":
		var bldg_icon = Data.icons[tile.bldg_str]
		match tile.bldg_str:
			"ME":
				$BuildingInformation.modulate = Color(0, 0.68, 1, 1)
			"PP":
				$BuildingInformation.modulate = Color(0, 0.68, 0, 1)
		$Icon.texture = bldg_icon

func add_bldg_info():
	if tile.bldg_str != "":
		$HBoxContainer/Label.visible = true
		match tile.bldg_str:
			"ME", "PP":
				tile.bldg_info = {"collect_date":tile.construction_date + tile.construction_length, "stored":0, "path_1":1, "path_2":1, "path_1_value":Data.path_1[tile.bldg_str].value, "path_2_value":Data.path_2[tile.bldg_str].value}


func _on_Label_mouse_entered():
	game.show_tooltip(tr("PATH_1") + " " + tr("LEVEL") + " " + String(tile.bldg_info.path_1))


func _on_Label_mouse_exited():
	game.hide_tooltip()


func _on_Label2_mouse_entered():
	game.show_tooltip(tr("PATH_2") + " " + tr("LEVEL") + " " + String(tile.bldg_info.path_2))


func _on_Label3_mouse_entered():
	game.show_tooltip(tr("PATH_3") + " " + tr("LEVEL") + " " + String(tile.bldg_info.path_3))
