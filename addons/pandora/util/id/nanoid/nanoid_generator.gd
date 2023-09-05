# inspired by github.com/eth0net/nanoid-godot (MIT) v0.2.0
class_name PandoraNanoIDGenerator
extends PandoraIDGenerator


const ALPHABET := "useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict"
const SIZE := 21


var size: int


func _init(size := SIZE) -> void:
	self.size = size


func generate() -> String:
	var id: String
	for i in range(size):
		id += ALPHABET[randi() % ALPHABET.length()]
	return id
