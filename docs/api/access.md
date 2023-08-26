# Accessing Data

> ⚠️ this functionality is still in alpha state. Exporting custom types is currently not possible. Refer to [#44](https://github.com/bitbrain/pandora/issues/44) for more information.

Within Pandora, data is available at your fingertips, either from a `PandoraCategory` or a `PandoraEntity`. The functions at your disposal are:

- `get_string`
- `get_int`
- `get_float`
- `get_bool`
- `get_color`
- `get_reference`
- `get_resource`

Example:

To paint a clearer picture, here's how you can access the data:

```gdscript
func _ready() -> void:
   var sword = Pandora.get_entity(EntityIds.SWORD) # PandoraEntity type
   var damage = sword.get_float("Damage") # float type
```

In this example, the `Damage` property of the `SWORD` entity is fetched, demonstrating how effortlessly you can interact with Pandora's data structure within your game script.

## Entity Exports

Pandora allows you to define entities on nodes directly inside the editor. This can be done as follows:
```gdscript
extends Node2D

@export var sword:PandoraEntity

func _ready() -> void:
   var instance:PandoraEntityInstance = sword.instantiate()
```
Within the Godot node editor properties, then select the entity of your choice from the list!

## Type checks

Pandora provides various ways to check if an entity is of a specific "type".

### Static Type Check

```gdscript
if entity is CustomType:
   # entity is CustomType, only works if:
   # 1. a parent category of entity has the CustomType script set
   # 2. CustomType extends PandoraEntity
```
✅ **Advantage**: type-safe and allows for auto-completion</br>
😕 **Downside**: requires extra scripts to do type-checks

### Direct Category Check

```gdscript
if entity.get_category().get_entity_name() == "Category Name":
   # entity is of category with name
```

✅ **Advantage**: no additional setup required (quick)</br>
😕 **Downside**: can be unsafe, in case category gets renamed. Also, can only check for direct parent.

### Is Category Check

```gdscript
if entity.is_category("42"):
   # any parent category of entity has id "42"
```

✅ **Advantage**: no additional setup required (quick)</br>
😕 **Downside**: requires "guessing" of parent category id (can be checked in the editor by hovering the category name).

### Is Category Check (by name constant)

```gdscript
if entity.is_category(Items.CATEGORY_ORES):
   # entity is under the Ores category
```

✅ **Advantage**: no additional setup required (quick)</br>
😕 **Downside**: currently not possible, requires [#63](https://github.com/bitbrain/pandora/issues/63) to be done first!