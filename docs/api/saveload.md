# Saving and Loading

Pandora allows you to load and save changed data effortlessly. The data defined inside the Pandora editor itself will be shipped as part of your game files in `res://data.pandora`, while there might also be a separate state for save games, e.g. in `user://savegame.json`. Given this architecture, it's clear that directly modifying PandoraEntity during runtime and then saving it isn't straightforward, because PandoraEntity is fundamentally a static model descriptor. To manipulate game data, you'd first need to [create an instance of your entity](api/instancing):

```gdscript

var sword:PandoraEntityInstance

func _ready() -> void:
   self.sword = Pandora.get_entity(EntityIds.SWORD).instanciate()
```

With PandoraEntityInstance in hand, you might think of writing game data to a JSON file. For a comprehensive overview of setting up a savegame system in Godot, [check out this guide](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html). Here is [a practical `SaveGame` mechanism example](https://github.com/bitbrain/godot-gamejam/blob/main/godot/savegame/SaveGame.gd) to help you visualize it better.

Given such an architecture, you might have a function that uses a dictionary to manage save and load operations:

```gdscript
func save_game() -> Dictionary:
   var data = {}
   data["sword"] = Pandora.serialize(sword)
   return data
```
Pandora ensures serialization is in a format it can readily understand. When you're set to restore an entity instance, it can be done like so:
```gdscript
func load_game(data:Dictionary) -> void:
   sword = Pandora.deserialize(data["sword"])
```
With these tools, managing game state becomes a seamless experience.