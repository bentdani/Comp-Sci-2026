extends Node3D

func _on_p_1_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	print("p1")
	var sister = get_parent().get_node("timer_ui")
	sister.is_running = true
