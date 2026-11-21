extends Node2D
func _process(_delta: float) -> void:
	queue_redraw()
func _draw() -> void:
	var game=get_parent()
	game.defence_system.draw_fx(game,self)
	game._draw_navigation_marker(self)
