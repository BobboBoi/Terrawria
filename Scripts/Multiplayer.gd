extends Node
class_name MultiplayerTool

var PORT = 25565
var enetPeer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var address
var players : Array = []
var playerCount : int = 0
var host = false
var multi = false

#Local client data
var userName : String = "UserName"
var playerIndex : int = 0 #index of client in players array
var clientId : int = 0

signal NewPlayer(id : int)

##Setup multiplayer server
func _host():
	host = true
	multi = true
	print("Hosting on port: ",PORT)
	enetPeer.create_server(PORT,4)
	multiplayer.multiplayer_peer = enetPeer
	
	multiplayer.peer_connected.connect(SpawnPlayer)
	SpawnPlayer(multiplayer.get_unique_id())

##Connect to server and create client
func _join():
	multi = true
	print("Joining: ",address,":",PORT)
	enetPeer.create_client(address,PORT)
	multiplayer.multiplayer_peer = enetPeer

##Connect callable to the NewPlayer signal.[br]
##The callable must have an int parameter.
func Sync(callable : Callable):
	connect("NewPlayer",callable)

##Set target address to join
func _address(Address : String):
	address = Address

##Set target port to join
func _port(port : String):
	PORT = port.to_int()

##Set username
func setName(username : String):
	userName = username

##Add a player to the list and emit new player
func SpawnPlayer(id):
	if players.find(id) == -1:
		playerCount += 1
		players.append(id)
		NewPlayer.emit(id)
	
	for i in players:
		multiplayer.rpc(i,self,"SyncPlayerList",[players])

@rpc("authority","call_local")
func SyncPlayerList(newList : Array):
	players = newList

func IsClient() -> bool:
	return multi and !host
