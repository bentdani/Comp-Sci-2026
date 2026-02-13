extends Node3D
var intital_pos = Vector3(0, 20.552, 710.458)
var intital_ros = Vector3(0, -100, 0)

func _on_delete_body_entered(body: Node3D) -> void:
	print("die kealen")
	$Player_Car.position = intital_pos
	$Player_Car.rotation = intital_ros
