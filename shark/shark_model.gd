extends Node3D

@onready var movement_sm: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/Movement/playback")
@onready var face_sm: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/FaceExpression/playback")

func idle_anim():
	movement_sm.travel("Shark_Idle")

func open_mouth_anim():
	face_sm.travel("Shark_Mouth_Open")
	
func close_mouth_anim():
	face_sm.travel("Shark_Mouth_Shut")
