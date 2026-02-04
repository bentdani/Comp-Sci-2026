extends Node3D

@export var path: Path3D

var track_length := 0.0
var progress := 0.0  

func _ready():
	track_length = path.curve.get_baked_length()

func _physics_process(_delta):
	var curve := path.curve

	var closest := curve.get_closest_offset(global_position)

	var delta := closest - progress

	if delta < -track_length * 0.5:
		delta += track_length
	elif delta > track_length * 0.5:
		delta -= track_length

	if delta > 0.0:
		progress += delta

	progress = fmod(progress, track_length)

	var percent := (progress / track_length) * 100.0
	print(percent)
