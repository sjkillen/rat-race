@tool

extends Node

func make_letter(l):
	var a: Label = preload("res://menus/animated_logo_letter.tscn").instantiate()
	a.name = l
	a.text = l
	add_child(a)
	a.owner = owner
	print("Making ", l)

func make_logo():
	for l in "rat race":
		make_letter(l)

@export_tool_button("make logo") var ml = make_logo

	
@export_tool_button("Hello", "Callable") var hello_action = hello

func hello():
	print("Hello world!")
