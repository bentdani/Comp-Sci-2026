extends RigidBody3D

@export_group("Suspension")
@export var suspension_rest_dist: float = 0.6  # How high the car floats
@export var spring_strength: float = 400.0     # F1 stiffness
@export var spring_damping: float = 30.0       # Anti-bounce

@onready var rays = [
	$"Suspension/RayCast3D (front left)", 
	$"Suspension/RayCast3D (front right)", 
	$"Suspension/RayCast3D (back left)", 
	$"Suspension/RayCast3D (back right)"
]

func _physics_process(_delta):
	for ray in rays:
		if ray.is_colliding():
			# Calculate the "spring" math
			var collision_point = ray.get_collision_point()
			var distance = (ray.global_transform.origin - collision_point).length()
			
			var spring_dir = ray.global_transform.basis.y
			# Manual velocity calculation: linear velocity + angular velocity cross product
			var tire_velocity = linear_velocity + angular_velocity.cross(ray.global_transform.origin - global_transform.origin)
			
			var offset = suspension_rest_dist - distance
			var velocity_on_spring_axis = spring_dir.dot(tire_velocity)
			
			# Calculate final force
			var force = (offset * spring_strength) - (velocity_on_spring_axis * spring_damping)
			
			# Apply force exactly at the wheel position
			apply_force(spring_dir * force, ray.global_transform.origin - global_transform.origin)
