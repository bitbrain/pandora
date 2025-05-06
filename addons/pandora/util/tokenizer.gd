static var regex:RegEx

## Converts any string into a GDScript-valid token (cannot contain special characters)
static func tokenize(value:String) -> String:
	if regex == null:
		regex = RegEx.new()
		regex.compile("(^[^A-Z_\u4e00-\u9fa5])|([^A-Z0-9_\u4e00-\u9fa5])")
	var token = value.to_upper()

	var regex_matches = regex.search_all(token)
	var offset = 0
	for regex_match in regex_matches:
		var start = regex_match.get_start()
		var end = regex_match.get_end()
		var length = end - start
		var text = token.substr(start + offset, length)
		var replacement = "_"
		token = token.substr(0, start + offset) + replacement + token.substr(end + offset)
		offset += replacement.length() - text.length()

	return token
