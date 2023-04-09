## Generates unique ids based on a pseudo UUID algorithm incorperating
## system time, process id and random numbers.
static func generate(seed = 0) -> String:
	var timestamp = int(Time.get_unix_time_from_system())
	var process_id = OS.get_process_id()

	if seed == 0:
		randomize()
	else:
		seed(seed)
		timestamp = seed
		process_id = seed

	return "%08x-%04x-%04x-%04x-%012x" % [
		timestamp % (1 << 32),
		(timestamp >> 32) % (1 << 16),
		process_id % (1 << 16),
		randi() % (1 << 16),
		randi() % (1 << 48)
	]
