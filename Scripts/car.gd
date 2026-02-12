extends RigidBody3D

@export_group("Suspension")
@export var suspension_rest_dist: float = 0.6
@export var spring_strength: float = 500.0 # Bumped up for stability
@export var spring_damping: float = 40.0

@export_group("Driving")
@export var engine_force: float = 12000.0 # Reduced: applied per wheel
@export var steering_limit: float = 0.5
@export var grip_strength: float = 15.0  # Increased for snappier response
@export var downforce: float = 20.0

@onready var rays = [
	$"Suspension/RayCast3D (front left)", 
	$"Suspension/RayCast3D (front right)", 
	$"Suspension/RayCast3D (back left)", 
	$"Suspension/RayCast3D (back right)"
]

@onready var pivots = [$Look_At_Node/Wheels/FrontLeft_Steer, $Look_At_Node/Wheels/FrontRight_Steer]

func _physics_process(delta):
	var accel_input = Input.get_axis("ui_down", "ui_up")
	var steer_input = Input.get_axis("ui_right", "ui_left")

	# 1. Handle Steering Visuals & Logic
	var steer_angle = steer_input * steering_limit
	for p in pivots:
		p.rotation.y = lerp(p.rotation.y, steer_angle, 0.2)

	# 2. Process Each Wheel
	for i in range(rays.size()):
		var ray = rays[i]
		if ray.is_colliding():
			var force_pos = ray.get_collision_point() - global_position
			var ray_dir = -ray.global_transform.basis.y # Gravity direction
			
			# Current velocity at the point where the wheel touches ground
			var point_vel = linear_velocity + angular_velocity.cross(force_pos)
			
			# --- 1. SUSPENSION ---
			var dist = (ray.global_transform.origin - ray.get_collision_point()).length()
			var spring_depth = suspension_rest_dist - dist
			var spring_vel = ray_dir.dot(point_vel)
			var total_spring_force = (spring_depth * spring_strength) - (spring_vel * spring_damping)
			
			# Apply upward force
			apply_force(-ray_dir * total_spring_force, force_pos)

			# --- 2. GRIP & STEERING ---
			# We need to know which way the wheel is facing
			var wheel_basis = ray.global_transform.basis
			if i < 2: # Front wheels rotate
				wheel_basis = wheel_basis.rotated(Vector3.UP, pivots[0].rotation.y)
			
			var forward_dir = -wheel_basis.z
			var right_dir = wheel_basis.x
			
			# Sideways friction (The "Grip")
			var side_vel = right_dir.dot(point_vel)
			var grip_impulse = -side_vel * grip_strength * (mass / 4.0)
			apply_force(right_dir * grip_impulse, force_pos)
			
			# Forward Engine Force
			if accel_input != 0:
				apply_force(forward_dir * accel_input * (engine_force / 4.0), force_pos)

	# 3. GLOBAL DOWNFORCE (Keeps it from flying)
	apply_central_force(Vector3.DOWN * linear_velocity.length() * downforce)

	# 4. ANTI-FLIP (Low Center of Mass)
	# This force pushes the car upright if it leans too far
	var up_dir = global_transform.basis.y
	var tilt_correction = up_dir.cross(Vector3.UP)
	apply_torque(tilt_correction * 500.0)
