# scripts/MainMenu.gd
# Controller-navigable main menu.
# D-pad / left stick navigates between buttons; A / Enter confirms; Start Run → Game.
extends Node


func _ready() -> void:
	$CanvasLayer/CenterContainer/VBoxContainer/StartButton.grab_focus()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
