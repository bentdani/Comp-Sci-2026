extends Node3D

var start_time = 0.0
var elapsed_time = 0.0
var is_running = false
var pb: float = 0
var save_path = "user://racing_stats.cfg"

func _ready() -> void:
	load_pb()
	if pb == 0:
		$CanvasLayer/pb.text = "Record Lap: null"
	else:
		$CanvasLayer/pb.text = "Record Lap: " + str(format_time(pb))
			
func _process(_delta):
	if is_running == true:
		elapsed_time = Time.get_ticks_msec() - start_time
		if str(format_time(elapsed_time)) == null:
			$CanvasLayer/StopwatchLabel.text = "Time: 00:00:000"
		else:
			$CanvasLayer/StopwatchLabel.text = "Time: " + str(format_time(elapsed_time))
			
		if pb == 0:
			$CanvasLayer/pb.text = "Record Lap: null"
		else:
			$CanvasLayer/pb.text = "Record Lap: " + str(format_time(pb))

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
		reset_stopwatch()
