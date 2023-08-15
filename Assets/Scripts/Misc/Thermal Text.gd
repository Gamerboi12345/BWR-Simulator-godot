extends Label3D
@onready var node_3d = $"/root/Node3d"

@onready var therm_text = %"ThermalText"

func _ready():
	while true:
		var power = $"/root/Node3d/Reactor".total_core_power_percent*3600
		therm_text.text = str(power)
		await get_tree().create_timer(0.1).timeout
