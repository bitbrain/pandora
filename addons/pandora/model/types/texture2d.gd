extends PandoraPropertyType

const ICON_PATH = "res://addons/pandora/icons/Texture2d.svg"

const SETTINGS = {}


func _init() -> void:
	super("texture2d", SETTINGS, null, ICON_PATH)


func parse_value(variant: Variant, settings: Dictionary = {}) -> Variant:
	if variant is String:
		if variant == "":
			return null

		var deserialized = JSON.parse_string(variant)
		if deserialized["type"] == "AtlasTexture":
			var t = AtlasTexture.new()
			t.atlas = load(deserialized["path"])
			t.region = Rect2(
				deserialized["region"][0],
				deserialized["region"][1],
				deserialized["region"][2],
				deserialized["region"][3],
			)
			return t

		# Defaults to loading a texture2d
		var t = Texture2D.new()
		t.load(deserialized["path"])
		return t

	return variant


func write_value(variant: Variant) -> Variant:
	if variant == null:
		return ""

	var texture2d = variant as Texture2D
	var serialized = {
		"path": texture2d.resource_path,
		"type": texture2d.get_class(),
	}
	if texture2d is AtlasTexture:
		if texture2d.atlas == null:
			return ""

		serialized["path"] = texture2d.atlas.resource_path
		serialized["region"] = [
			texture2d.region.position.x,
			texture2d.region.position.y,
			texture2d.region.size.x,
			texture2d.region.size.y,
		]

	return JSON.stringify(serialized)


func is_valid(variant: Variant) -> bool:
	return variant is Texture2D
