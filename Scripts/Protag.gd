extends CharacterBody3D

const MAX_AMMO = 10;

const AMMO_SPRITE_WIDTH = 16;
const AMMO_SPRITE_HEIGHT = 65;
const HP_SPRITE_WIDTH = 77;
const HP_SPRITE_HEIGHT = 65;

@export var speed = 4
var model: Node3D 
var bullet: PackedScene  = preload("res://Prefabs/bullet.tscn")
var minusHPParticle: PackedScene = preload("res://Prefabs/Particles/damage_particle.tscn");

@onready var ammoMeter: TextureRect = $Control/AmmoMeter
@onready var hpMeter: TextureRect = $Control/HpMeter

@onready var reloadingLabel: Label3D = $ReloadingLabel
@onready var outOfAmmoLabel: Label3D = $OutOfAmmoLabel

@onready var reloadTimer: Timer = $ReloadTimer
@onready var contactDamageTimer: Timer = $ContactDamageTimer
@onready var damageTimer: Timer = $DamageTimer
@onready var animationTree: AnimationTree = $Model/Body/AnimationTree


var gunDirection: Node3D
var level: Node3D
var ammo: Array

var ammoValue = MAX_AMMO
var currentBullet = 0
var health = 3
var canBeDamaged = true
var collided = false

func get_input(delta):
	# Input handling
	var movement: Vector3 = Vector3.ZERO
	movement.x = Input.get_action_strength("left") - Input.get_action_strength("right")
	movement.z = Input.get_action_strength("up") - Input.get_action_strength("down")
	# Normalize the movement vector to avoid faster diagonal movement
	movement = movement.normalized()
	# Apply movement
	velocity.x = movement.x * speed
	velocity.z = movement.z * speed
	animationTree.set("parameters/conditions/moving", movement.x != 0 || movement.z != 0);
	animationTree.set("parameters/conditions/idle", movement.x  == 0 && movement.z == 0);
	#Mouse
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var center: Vector2 = get_viewport().size / 2
	var angle: float = -Vector2.UP.angle_to(mouse_position - center)
	model.rotation = Vector3(model.rotation.x,lerp_angle(model.rotation.y, angle, delta * 100), model.rotation.z)
	
	if Input.is_action_just_pressed("shoot") && ammoValue > 0:
		ammo[currentBullet].set_process_mode(PROCESS_MODE_ALWAYS)
		ammo[currentBullet].show()
		ammo[currentBullet].position = gunDirection.global_position
		ammo[currentBullet].rotation = Vector3(model.rotation.x,lerp_angle(model.rotation.y, angle, delta * 100), model.rotation.z)
		currentBullet += 1
		ammoValue -= 1
		if currentBullet == 20:
			currentBullet = 0
		if(ammoValue == 0):
			outOfAmmoLabel.visible = true;
	if Input.is_action_just_pressed("reload"):
		outOfAmmoLabel.visible = false;
		reloadingLabel.visible = true;
		reloadTimer.start();
	ammoMeter.set_size(Vector2(AMMO_SPRITE_WIDTH * ammoValue, AMMO_SPRITE_HEIGHT));
	
# Called when the node enters the scene tree for the first time.
func _ready():
	model = get_node("Model")
	gunDirection = get_node("Model/GunDirection")
	level = get_parent()
	ammo = level.get_node("Bullets").get_children()
	hpMeter.set_size(Vector2(HP_SPRITE_WIDTH * health, HP_SPRITE_HEIGHT))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if collided && canBeDamaged:
		canBeDamaged = false
		takeDamage(1)
		damageTimer.start()
	pass
	
func _physics_process(delta):
	get_input(delta)
	move_and_slide()
	pass
	
func takeDamage(value):
	health -= value
	hpMeter.set_size(Vector2(HP_SPRITE_WIDTH * health, HP_SPRITE_HEIGHT));
	
	var particle = minusHPParticle.instantiate();
	particle.position = position;
	get_parent().add_child(particle);
		
	print(health);
	pass
	
func _on_reload_timer_timeout():
	outOfAmmoLabel.visible = false;
	reloadingLabel.visible = false;
	ammoValue = 10;
	ammoMeter.set_size(Vector2(AMMO_SPRITE_WIDTH * ammoValue, AMMO_SPRITE_HEIGHT));
	pass # Replace with function body.



func _on_area_3d_body_entered(body):
	if body.name != "Player":
		collided = true
	pass # Replace with function body.


func _on_area_3d_body_exited(body):
	collided = false
	pass # Replace with function body.s


func _on_damage_timer_timeout():
	damageTimer.stop()
	canBeDamaged = true
	pass # Replace with function body.


func _on_area_3d_area_entered(area):
	collided = true
	pass # Replace with function body.


func _on_area_3d_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	collided = false
	pass # Replace with function body.
