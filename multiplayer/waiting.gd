extends CanvasLayer


func enable_waiting():
	%WaitingCamera.set_current()
	visible = true

func disable_waiting():
	%WaitingCamera.unset_current()
	visible = false
