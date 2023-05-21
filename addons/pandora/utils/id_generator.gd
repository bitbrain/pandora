## Generates unique ids based on a pseudo UUID algorithm incorperating
## system time, process id and random numbers.

static func generate(seed = 0) -> String:
	var timestamp = int(Time.get_unix_time_from_system())
	var process_id = OS.get_process_id()
	var ticks = Time.get_ticks_msec()

	if seed == 0:
		randomize()
	else:
		seed(seed)
		timestamp = seed
		process_id = seed
		ticks = seed

	var random_number = randi_range(0, 99999999)

	return str(process_id) + str(timestamp) + str(ticks) + str(random_number)
