# Accessing Data

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