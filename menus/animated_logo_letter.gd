extends Label

@export var speed_curve: Curve

func _ready() -> void:
	var offset : float = randf_range(0.0, $LogoLetterAnimation.current_animation_length)
	%LogoLetterAnimation.advance(offset)
	$LogoLetterAnimation.speed_scale = speed_curve.sample(randf())
