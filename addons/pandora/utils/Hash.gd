static func hash_attributes(attributes:Array[Variant]) -> int:
	var hash_val = 5381

	for attribute in attributes:
		var attribute_str = str(attribute)
		for char in attribute_str:
			hash_val = ((hash_val << 5) + hash_val) + char.unicode_at(0)

	return hash_val

static func hash_str(input: String) -> int:
	var hash_val = 5381
	for char in input:
		hash_val = ((hash_val << 5) + hash_val) + char.unicode_at(0)
	return hash_val
