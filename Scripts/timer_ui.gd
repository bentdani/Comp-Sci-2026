extends Node3D

var start_time = 0.0
var elapsed_time = 0.0
var is_running = false
var total_start_time = 0.0
var lap_start_time = 0.0
var lap_1_final = 0.0
var lap_2_final = 0.0
var lap_3_final = 0.0
var pb: float = 0
var save_path = "user://racing_stats.cfg"
var Current_lap = 0

func _ready() -> void:
	$CanvasLayer/Lap_1.text = "Lap 1: Null"
	$CanvasLayer/Lap_2.text = "Lap 2: Null"
	$CanvasLayer/Lap_3.text = "Lap 3: Null"
	load_pb()
	if pb == 0:
		$CanvasLayer/pb.text = "Record Lap: null"
	else:
		$CanvasLayer/pb.text = "Record Lap: " + str(format_time(pb))
			
func _process(_delta):
	Current_lap = Global.current_lap
	if pb == 0:
		$CanvasLayer/pb.text = "Record Lap: null"
	else:
		$CanvasLayer/pb.text = "Record Lap: " + str(format_time(pb))
	
	if is_running == true:
		start_new_lap()
		var current_time = Time.get_ticks_msec()
		elapsed_time = current_time - total_start_time
		var current_lap_duration = current_time - lap_start_time
		
		# Update the Main Stopwatch (Total Time)
		$CanvasLayer/StopwatchLabel.text = "Total: " + format_time(elapsed_time)
		
		if Current_lap == 0:
			$CanvasLayer/StopwatchLabel.text = "Time: 00:00:000"
			$CanvasLayer/Lap_1.text = "Lap 1: Null"
			$CanvasLayer/Lap_2.text = "Lap 2: Null"
			$CanvasLayer/Lap_3.text = "Lap 3: Null"
		else:
			$CanvasLayer/StopwatchLabel.text = "Time: " + str(format_time(elapsed_time))
			
			
		if Current_lap == 1:
			$CanvasLayer/Lap_1.text = "Lap 1: " + format_time(current_lap_duration)
		elif Current_lap == 2:
			$CanvasLayer/Lap_2.text = "Lap 2: " + format_time(current_lap_duration)
		elif Current_lap == 3:
			$CanvasLayer/Lap_3.text = "Lap 3: " + format_time(current_lap_duration)

func start_new_lap():
	var now = Time.get_ticks_msec()

	if Current_lap == 1:
		start_stopwatch()
		total_start_time = now
		lap_start_time = now
		is_running = true
	elif Current_lap == 2:
		# Crossed for Lap 2: Lap 1 is finished
		lap_1_final = now - lap_start_time
		$CanvasLayer/Lap_1.text = "Lap 1: " + format_time(lap_1_final)
		lap_start_time = now # Reset for Lap 2
	elif Current_lap == 3:
		# Crossed for Lap 3: Lap 2 is finished
		lap_2_final = now - lap_start_time
		$CanvasLayer/Lap_2.text = "Lap 2: " + format_time(lap_2_final)
		lap_start_time = now # Reset for Lap 3
	elif Current_lap == 4:
		# Finished the race!
		lap_3_final = now - lap_start_time
		$CanvasLayer/Lap_3.text = "Lap 3: " + format_time(lap_3_final)
		stop_stopwatch()

func save_pb():
	var config = ConfigFile.new()
	config.set_value("Records", "fastest_lap", pb)
	config.save(save_path)
	print("PB Saved to disk!")

func load_pb():
	var config = ConfigFile.new()
	var error = config.load(save_path)
	if error == OK:
		pb = config.get_value("Records", "fastest_lap", 0.0)
		print("PB Loaded: ", pb)

func start_stopwatch():
	start_time = Time.get_ticks_msec()
	is_running = true

func stop_stopwatch():
	is_running = false
	if elapsed_time > 0.1: 
		if pb == 0 or elapsed_time < pb:
			pb = elapsed_time
			save_pb()
			print("New Personal Best: ", pb)

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
		Current_lap = 0
		stop_stopwatch()
