extends Node3D
var intital_pos = Vector3(874.514, 5.702, -356.598)
var intital_ros = Vector3(0, -119.2, 0)

func _on_delete_body_entered(body: Node3D) -> void:
	print("die kealen")
	$Player_Car.position = intital_pos
	$Player_Car.rotation = intital_ros
	$Player_Car.linear_velocity = Vector3(0,0,0)
	$Player_Car.angular_velocity = Vector3(0,0,0)
