extends CharacterBody3D

var turn_mult = 25

var udp = PacketPeerUDP.new()
var port = 6767

var turn:float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	if udp.bind(port) != OK:
		print("Error binding to port: ", port)
		return
	print("Listening on port ", port)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	while udp.get_available_packet_count() > 0:
		var bytes = udp.get_packet()
		var data = bytes.decode_float(0)
		turn = snappedf(data, 0.01)
		turn = clampf(turn, -1.0, 1.0)
	
	print(turn)
	position.x = turn * turn_mult
		
