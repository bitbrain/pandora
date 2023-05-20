static func merge_dictionaries(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var merged_dict = Dictionary()
	
	for key in dict1:
		merged_dict[key] = dict1[key]
	
	for key in dict2:
		merged_dict[key] = dict2[key]
	
	return merged_dict
