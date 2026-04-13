extends Node3D

var start_time = 0.0
var elapsed_time = 0.0
var is_running = false
var total_start_time = 0.0
var lap_start_time = 0.0
var lap_1_final = 0.0
var lap_2_final = 0.0
var lap_3_final = 0.0
var best_lap: float = 0.0
var best_overall: float = 0.0
var save_path = "user://racing_stats.cfg"
var Current_lap = 0
var previous_lap = 0

func _ready() -> void:
	$CanvasLayer/Lap_1.text = "Lap 1: Null"
	$CanvasLayer/Lap_2.text = "Lap 2: Null"
	$CanvasLayer/Lap_3.text = "Lap 3: Null"
	load_pb()
			
func _process(_delta):
	Current_lap = Global.current_lap
	
	# Put this near the top of your _process function
	if best_lap == 0.0:
		$CanvasLayer/pb.text = "Best Lap: --:--.---"
	else:
		$CanvasLayer/pb.text = "Best Lap: " + format_time(best_lap)
		
	if best_overall == 0.0:
		$CanvasLayer/pb2.text = "Best Overall: --:--.---"
	else:
		$CanvasLayer/pb2.text = "Best Overall: " + format_time(best_overall)
		
	if Current_lap != previous_lap:
		start_new_lap()
		previous_lap = Current_lap
	
	if Current_lap == 0:
		$CanvasLayer/StopwatchLabel.text = "Time: null"
		$CanvasLayer/Lap_1.text = "Lap 1: null"
		$CanvasLayer/Lap_2.text = "Lap 2: null"
		$CanvasLayer/Lap_3.text = "Lap 3: null"
	if is_running == true:
		var now = Time.get_ticks_msec()
		var total_elapsed = now - total_start_time
		var current_lap_elapsed = now - lap_start_time
		
		$CanvasLayer/StopwatchLabel.text = "Time: " + format_time(total_elapsed)
		
	# Update the current lap's ticking UI
		if Current_lap == 1:
			$CanvasLayer/Lap_1.text = "Lap 1: " + format_time(current_lap_elapsed)
		elif Current_lap == 2:
			$CanvasLayer/Lap_2.text = "Lap 2: " + format_time(current_lap_elapsed)
		elif Current_lap == 3:
			$CanvasLayer/Lap_3.text = "Lap 3: " + format_time(current_lap_elapsed)
	
func start_new_lap():
	var now = Time.get_ticks_msec()
	if Current_lap == 0:
			lap_1_final = 0
			lap_2_final = 0
			is_running = false
	elif Current_lap == 1:
		start_stopwatch()
		total_start_time = now
		lap_start_time = now
		is_running = true
	elif Current_lap == 2:
		lap_1_final = now - lap_start_time
		$CanvasLayer/Lap_1.text = "Lap 1: " + format_time(lap_1_final)
		check_best_lap(lap_1_final) # <--- CHECK LAP 1
		lap_start_time = now 
	elif Current_lap == 3:
		lap_2_final = now - lap_start_time
		$CanvasLayer/Lap_2.text = "Lap 2: " + format_time(lap_2_final)
		check_best_lap(lap_2_final) # <--- CHECK LAP 2
		lap_start_time = now 
	elif Current_lap == 4:
		lap_3_final = now - lap_start_time
		$CanvasLayer/Lap_3.text = "Lap 3: " + format_time(lap_3_final)
		check_best_lap(lap_3_final) # <--- CHECK LAP 3
		stop_stopwatch()

func stop_stopwatch():
	is_running = false
	
	# Calculate the final total time right when the race ends
	var final_total_time = Time.get_ticks_msec() - total_start_time
	
	if final_total_time > 0.1: 
		if best_overall == 0.0 or final_total_time < best_overall:
			best_overall = final_total_time
			save_pb()
			print("New Best Overall Time: ", format_time(best_overall))

func save_pb():
	var config = ConfigFile.new()
	config.set_value("Records", "fastest_lap", best_lap)
	config.set_value("Records", "fastest_overall", best_overall)
	config.save(save_path)
	print("Records Saved to disk!")

func check_best_lap(lap_time: float):
	# If it's our first time setting a record, OR if the new time is faster
	if best_lap == 0.0 or lap_time < best_lap:
		best_lap = lap_time
		save_pb()
		print("New Best Lap: ", format_time(best_lap))

func load_pb():
	var config = ConfigFile.new()
	var error = config.load(save_path)
	if error == OK:
		best_lap = config.get_value("Records", "fastest_lap", 0.0)
		best_overall = config.get_value("Records", "fastest_overall", 0.0)
		print("PB Lap: ", best_lap, " | PB Overall: ", best_overall)

func start_stopwatch():
	start_time = Time.get_ticks_msec()
	is_running = true


func reset_stopwatch():
	is_running = false
	elapsed_time = 0.0
	$CanvasLayer/StopwatchLabel.text = "Time: 00:00.000"

func format_time(msec: float) -> String:
	"integer_division"
	var total_seconds = msec / 1000
	"integer_division"
	var minutes = total_seconds / 60
	var seconds = int(total_seconds) % 60
	var milliseconds = int(msec) % 1000

	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
	

func _on_delete_body_entered(body: Node3D) -> void:
	if body.name == "Player_Car":
		Global.current_lap = 0
