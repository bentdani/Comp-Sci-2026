extends RigidBody3D

@export_group("Suspension")
@export var suspension_rest_dist: float = 0.6
@export var spring_strength: float = 400.0
@export var spring_damping: float = 30.0

@export_group("Driving")
@export var engine_force: float = 48000.0
@export var steering_limit: float = 0.15
@export var grip_strength: float = 5.0  # Keeps the car from sliding sideways
@export var downforce_stiffness: float = 10.0 # Start here and increase if still flipping

@onready var rays = [
	$"Suspension/RayCast3D (front left)", 
	$"Suspension/RayCast3D (front right)", 
	$"Suspension/RayCast3D (back left)", 
	$"Suspension/RayCast3D (back right)"
]

@onready var wheels = [
	$Look_At_Node/Wheels/FrontLeft_Steer/MeshInstance3D,
	$Look_At_Node/Wheels/FrontRight_Steer/MeshInstance3D3,
	$Look_At_Node/Wheels/MeshInstance3D5,
	$Look_At_Node/Wheels/MeshInstance3D6
]

# Nodes for visual steering
@onready var front_left_pivot = $Look_At_Node/Wheels/FrontLeft_Steer
@onready var front_right_pivot = $Look_At_Node/Wheels/FrontRight_Steer

func _physics_process(_delta):
	# 1. Get Inputs
	var accel_input = Input.get_axis("ui_down", "ui_up")
	var steer_input = Input.get_axis("ui_right", "ui_left") # Flipped for standard steering

	# 2. Visual Steering (Rotate the pivots you made yesterday)
	front_left_pivot.rotation.y = steer_input * steering_limit
	front_right_pivot.rotation.y = steer_input * steering_limit

	for i in range(rays.size()):
		var ray = rays[i]
		if ray.is_colliding():
			var collision_point = ray.get_collision_point()
			var ray_origin = ray.global_transform.origin
			var distance = (ray_origin - collision_point).length()
			var ray_relative_pos = ray_origin - global_transform.origin
			
			# Velocity at this specific wheel
			var tire_velocity = linear_velocity + angular_velocity.cross(ray_relative_pos)
			
			# --- SUSPENSION FORCE ---
			var spring_dir = ray.global_transform.basis.y
			var offset = suspension_rest_dist - distance
			var velocity_on_spring_axis = spring_dir.dot(tire_velocity)
			var s_force = (offset * spring_strength) - (velocity_on_spring_axis * spring_damping)
			apply_force(spring_dir * s_force, ray_relative_pos)

			# --- DRIVING & STEERING FORCE ---
			# Use the front wheel pivots to decide which way to push
			var wheel_basis = ray.global_transform.basis
			if i < 2: # If it's the front two wheels
				wheel_basis = wheel_basis.rotated(Vector3.UP, steer_input * steering_limit)
			
			var forward_dir = -wheel_basis.z # Forward is usually -Z in Godot
			var right_dir = wheel_basis.x
			
			# 1. Forward Acceleration
			apply_force(forward_dir * accel_input * (engine_force / 4.0), ray_relative_pos)
			
			# 2. Side Friction (Grip) - Prevents sliding like ice
			var side_velocity = right_dir.dot(tire_velocity)
			var grip_force = -side_velocity * grip_strength * (mass / 4.0)
			apply_force(right_dir * grip_force, ray_relative_pos)
			
			# Simple Anti-Roll Logic
			var left_dist = ($"Suspension/RayCast3D (front left)".get_collision_point() - $"Suspension/RayCast3D (front left)".global_transform.origin).length()
			var right_dist = ($"Suspension/RayCast3D (front right)".get_collision_point() - $"Suspension/RayCast3D (front right)".global_transform.origin).length()

			var roll_force = (left_dist - right_dist) * 500.0 # Adjust 500.0 to change stiffness
			apply_force(Vector3.UP * roll_force, $"Suspension/RayCast3D (front left)".position)
			apply_force(Vector3.UP * -roll_force, $"Suspension/RayCast3D (front right)".position)

	var speed = linear_velocity.dot(-global_transform.basis.z)
	var wheel_spin = (speed / 0.35) * _delta
	
	for wheel in wheels:
		if wheel:
			wheel.rotate_x(wheel_spin)
	
	var steering_velocity_multiplier = clamp(1.0 - (abs(speed) / 50.0), 0.2, 1.0)
	var final_steer_angle = steer_input * steering_limit * steering_velocity_multiplier

	# Smoothly rotate the steering pivots
	front_left_pivot.rotation.y = lerp(front_left_pivot.rotation.y, final_steer_angle, 0.1)
	front_right_pivot.rotation.y = lerp(front_right_pivot.rotation.y, final_steer_angle, 0.1)

	var current_speed = linear_velocity.length()
	# We calculate a force pointing "down" relative to the car's floor
	var down_direction = -global_transform.basis.y 
	var final_downforce = down_direction * current_speed * downforce_stiffness

	apply_central_force(final_downforce)
