extends Node3D

var start_time = 0.0
var elapsed_time = 0.0
var is_running = false

func _process(_delta):
	if is_running:
		# Calculate time in milliseconds
		elapsed_time = Time.get_ticks_msec() - start_time
		$CanvasLayer/Stopwatch.text = str(format_time(elapsed_time))

func start_stopwatch():
	start_time = Time.get_ticks_msec()
	is_running = true

func stop_stopwatch():
	is_running = false

func format_time(msec: int) -> String:
	"integer_division"
	var total_seconds = msec / 1000
	"integer_division"
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	var milliseconds = msec % 1000
	
	# Returns format: 01:24.003
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
