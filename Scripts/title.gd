extends Node2D

var game = preload("res://Scenes/Track.tscn")


func _on_play_button_down() -> void:
	get_parent().add_child(game.instantiate())
	queue_free()


func _on_quit_button_down() -> void:
	get_tree().quit()
