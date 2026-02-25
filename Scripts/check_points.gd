extends Node3D
	
func _on_p_1_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	get_parent().get_node("timer_ui").start_stopwatch()


func _on_p_1_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	get_parent().get_node("timer_ui").stop_stopwatch()
