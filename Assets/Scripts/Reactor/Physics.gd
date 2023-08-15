extends Node

@onready var node3d = $"/root/Node3d"

var total_core_power_percent = 1
var total_core_flow_percent = 40
var average_insertion = 100

var fuel_rods = {}



func calc_rod_power(rod):
	var core_power = total_core_power_percent
	var voiding = fuel_rods[rod]["rod_voiding_percent"]
	if voiding == 0:
		voiding = 0.1
	if fuel_rods[rod]["rod_neutron_block_percent"] != 100 and fuel_rods[rod]["rod_power_percent"] == 0:
		core_power = 0.00001
	if fuel_rods[rod]["rod_neutron_block_percent"] <100:
		return (((core_power/fuel_rods[rod]["rod_neutron_block_percent"])*100)/average_insertion)
	else:
		return 0
	
func calc_neutron_block(rod):
	var rod_insertion = 0
	if fuel_rods[rod]["nearest_cr"] in node3d.control_rods:
		rod_insertion = node3d.control_rods[fuel_rods[rod]["nearest_cr"]]["cr_insertion"]
	rod_insertion = abs(rod_insertion-48)*100
	if rod_insertion == 0:
		rod_insertion = 0.1
	
	
	return rod_insertion
	
func _ready():
	await node3d.ready
	for cr in node3d.control_rods:
		fuel_rods[cr] = {
			"rod_power_percent": 0,
			"rod_xenon_percent": 0,
			"rod_temperature": 20,
			"rod_voiding_percent": 0,
			"rod_neutron_block_percent": 100,
			"nearest_cr": cr
		}
	
	while true:
		var new_core_power = 0.001
		for rodn in fuel_rods:
			var assembly = fuel_rods[rodn]
			var neutblock = calc_neutron_block(rodn)
			assembly["rod_neutron_block_percent"] = neutblock
			var rod_power = calc_rod_power(rodn)
			
			assembly["rod_temperature"] = assembly["rod_temperature"] + rod_power/50
			if assembly["rod_temperature"] >= 100:
				assembly["rod_voiding_percent"] = assembly["rod_temperature"]/total_core_flow_percent
			else:
				assembly["rod_voiding_percent"] = 0
			
			assembly["rod_power_percent"] = rod_power
			new_core_power = new_core_power + (rod_power/fuel_rods.size())
			average_insertion = average_insertion + (((abs(node3d.control_rods[rodn]["cr_insertion"]-48)/48)*100)/fuel_rods.size())
			
			if rod_power >= 90:
				node3d.open_scram_breakers("High Rod Power")
			#print(rodn)
		#	print(assembly["rod_voiding_percent"])
		#	print(assembly["rod_neutron_block_percent"])
		#	print(assembly["rod_temperature"])
		#	print(assembly["rod_power_percent"])
	
		print("core_power")
		print(new_core_power)
		total_core_power_percent = new_core_power

		await get_tree().create_timer(0.1).timeout
