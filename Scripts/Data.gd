extends Node

#When there are dictionaries within dictionaries (within dictionaries) in Game.gd data,
#they go here to make future editing easier
#
#var base_metal_costs = 	{	"ME":{"lead":50, "copper":50, "iron":60},
#							"PP":{"lead":50, "copper":75, "iron":40},
#						}

var path_1 = {	"ME":{"value":0.12, "desc":"@i %s/" + tr("SECOND"), "metal_costs":{"lead":50, "copper":50, "iron":60}},
				"PP":{"value":0.3, "desc":"@i %s/" + tr("SECOND"), "metal_costs":{"lead":50, "copper":50, "iron":60}},
				"RL":{"value":0.02, "desc":"@i %s/" + tr("SECOND"), "metal_costs":{"lead":100, "copper":150, "iron":150}},
	
}
var path_2 = {	"ME":{"value":15, "desc":tr("STORES_X") % [" @i %s"], "metal_costs":{"lead":50, "copper":50, "iron":60}},
				"PP":{"value":70, "desc":tr("STORES_X") % [" @i %s"], "metal_costs":{"lead":50, "copper":50, "iron":60}},
	
}

var costs = {	"ME":{"money":100, "energy":40, "time":8.0},
				"PP":{"money":80, "time":14.0},
				"RL":{"money":2000, "energy":800, "time":9.0},

}

var icons = {	"ME":load("res://Graphics/Icons/Minerals.png"),
				"PP":load("res://Graphics/Icons/Energy.png"),
				"RL":load("res://Graphics/Icons/SP.png"),
}

func reload():
	path_1.ME.desc = "@i %s/" + tr("SECOND")
	path_1.PP.desc = "@i %s/" + tr("SECOND")
	path_1.RL.desc = "@i %s/" + tr("SECOND")
	path_2.ME.desc = tr("STORES_X") % [" @i %s"]
	path_2.PP.desc = tr("STORES_X") % [" @i %s"]

var lakes = {	"water":{"color":Color(0.38, 0.81, 1.0, 1.0)}}

#Science for unlocking game features
var science_unlocks = {"SA":{"cost":100}}
