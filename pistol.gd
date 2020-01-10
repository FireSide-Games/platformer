extends Node

export var fire_rate: float = 0.5

var last_time_fired: float = 0.0

func fire(current_time: float) -> bool:
	if current_time - last_time_fired >= fire_rate:
		last_time_fired = current_time
		print("BANG")
		return true
	return false
