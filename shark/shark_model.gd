extends Node3D

@onready var movement_sm: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/Movement/playback")
@onready var face_sm: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/FaceExpression/playback")

func _ready() -> void:
	movement_sm.stop()
	await get_tree().create_timer(randf()).timeout
	idle_anim()

func idle_anim():
	movement_sm.travel("Shark_Idle")

func open_mouth_anim():
	face_sm.travel("Shark_Mouth_Open")
	
func close_mouth_anim():
	face_sm.travel("Shark_Mouth_Shut")
