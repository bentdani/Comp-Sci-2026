extends Node3D
var intital_pos = Vector3(874.514, 5.702, -356.598)
var intital_ros = Vector3(0, -119.2, 0)
var title = load("res://Scenes/title.tscn")
var laps = 0
var can_score = true

func _on_delete_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "Player_Car":
		print("die kealen")
		
		# 1. Reset Position and Rotation perfectly
		var new_transform = Transform3D()
		new_transform.basis = Basis.from_euler(Vector3(0, deg_to_rad(-119.2), 0))
		new_transform.origin = intital_pos
		body.global_transform = new_transform
		
		# 2. Kill all momentum
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		laps = 0
		can_score = true

func _process(_delta):
	# ... keep the timer code that is already here ...
	
	# Add this here to update every frame:
	var kmh = $Player_Car.linear_velocity.length() * 2.0
	$timer_ui/CanvasLayer/SpeedLabel.text = str(round(kmh)) + " km/h"
	Global.current_lap = laps
	if laps == 4:
		get_parent().add_child(title.instantiate())
		queue_free()
		

func _on_p_1_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player_Car" and can_score == true:
		laps += 1
		can_score = false
	
func _on_p_1_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player_Car":
		print(laps)
		
func _on_checkpoint_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player_Car":
		can_score = true
