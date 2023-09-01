# NanoID class from github.com/eth0net/nanoid-godot (MIT) v0.2.0
class_name NanoID


static func generate(size: int = NanoIDGenerator.DEFAULT_SIZE) -> String:
	return with_alphabet(NanoIDAlphabets.URL)


static func with_alphabet(alphabet: String, size: int = NanoIDGenerator.DEFAULT_SIZE) -> String:
	return NanoIDGenerator.new(alphabet).generate(size)
