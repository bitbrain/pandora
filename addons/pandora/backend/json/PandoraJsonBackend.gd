@tool
class_name PandoraJsonBackend extends PandoraDataBackend

const ICON = preload("res://addons/pandora/icons/pandora-json-icon.svg")
const DIRECTORY = "pandora"
const FILE_NAME_ITEM = "items.json"
const FILE_NAME_ITEM_CATEGORIES = "item-categories.json"
const FILE_NAME_ITEM_INSTANCES = "item-instances.json"
const FILE_NAME_INVENTORIES = "inventories.json"

var initialized = false

# [file, Dictionary[_id, PandoraIdentifiable]]
var cache:Dictionary = {}

func get_backend_name() -> String:
	return "Pandora default (json)"
	
	
func get_backend_description() -> String:
	return "Persists data via json files."
	
	
func get_backend_icon() -> Texture:
	return ICON


func save_all(identifiables:Array[PandoraIdentifiable]) -> void:
	for identifiable in identifiables:
		_update_cache(identifiable)
		
		
func load_by_ids(ids:Array[String]) -> Dictionary:
	if not initialized:
		_populate_cache_from_disk()
		initialized = true

	var data = {}
	
	for id in ids:
		var cache_area_key = _get_cache_area_from_id(id)
		var cache_area = cache[cache_area_key]
		if id in cache_area:
			data[id] = cache_area[id]
	
	return data


func load_all(filters:Array[Callable] = []) -> Array[PandoraIdentifiable]:
	if not initialized:
		_populate_cache_from_disk()
		initialized = true
	
	var result = []
	
	for cache_area_key in cache:
		var cache_area = cache[cache_area_key]
		for id in cache_area:
			var identifiable = cache_area[id]
			if _passes_filter(identifiable, filters):
				result.append(identifiable)					
			
	return result
	

	
func flush() -> bool:
	return true
	
	
func _passes_filter(identifiable:PandoraIdentifiable, filters:Array[Callable]) -> bool:
	if filters.is_empty():
		return true
	for filter in filters:
		if not filter.call(identifiable):
			return false
	return true


# upserts the cache with the given identifiable
func _update_cache(identifiable:PandoraIdentifiable) -> void:
	var cache_area = _get_cache_area(identifiable)

	if not cache_area in cache:
		cache[cache_area] = {}
	
	cache[cache_area][identifiable._id] = identifiable
	

func _get_cache_area_from_id(id:String) -> String:
	if id.begins_with("item"):
		return FILE_NAME_ITEM
	if id.begins_with("item-instance"):
		return FILE_NAME_ITEM_INSTANCES
	if id.begins_with("item-category"):
		return FILE_NAME_ITEM_CATEGORIES
	if id.begins_with("inventory"):
		return FILE_NAME_INVENTORIES
	return ""


func _get_cache_area(identifiable:PandoraIdentifiable) -> String:
	if identifiable is PandoraItem:
		return FILE_NAME_ITEM
	if identifiable is PandoraItemInstance:
		return FILE_NAME_ITEM_INSTANCES
	if identifiable is PandoraItemCategory:
		return FILE_NAME_ITEM_CATEGORIES
	if identifiable is PandoraInventory:
		return FILE_NAME_INVENTORIES
	return ""

func _populate_cache_from_disk() -> void:
	pass


