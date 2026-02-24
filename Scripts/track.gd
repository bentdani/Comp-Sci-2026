extends Node3D
var intital_pos = Vector3(874.514, 5.702, -356.598)
var intital_ros = Vector3(0, -119.2, 0)

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

func _process(_delta):
	# ... keep the timer code that is already here ...
	
	# Add this here to update every frame:
	var kmh = $Player_Car.linear_velocity.length() * 2.0
	$timer_ui/CanvasLayer/SpeedLabel.text = str(round(kmh)) + " km/h"
