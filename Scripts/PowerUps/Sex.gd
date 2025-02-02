extends Area3D

@onready var audio = $AudioStreamPlayer
@export var particlePrefab: PackedScene;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _powerUp():
	get_tree().current_scene.get_node("Player")._raise_health()
	audio.play()
	
func _emit_particle(position: Vector3):
	var particle = particlePrefab.instantiate();
	particle.position = position;
	get_parent().add_child(particle);
