# Entity Instancing

> ⚠️ this functionality is still in alpha state. Property changes on entities are not correctly migrated into instances. Refer to [#41](https://github.com/bitbrain/pandora/issues/41) for more information.

In the realm of game development, static entities often fall short. They don't account for a dynamic gaming environment where the player's actions can alter the state of an entity. Let's explore this using the example of a sword:
```gdscript
func _ready() -> void:
   var sword = Pandora.get_entity(EntityIds.SWORD) # PandoraEntity type
   var damage = sword.get_float("Damage") # float type

   ## How might one alter the damage a sword deals?
```
Enter `instantiate()`, Pandora's answer to this conundrum. An instanced version of `PandoraEntity`, it retains a connection to its parent blueprint but allows for overriding and adjusting values through these methods:

- `set_string`
- `set_int`
- `set_float`
- `set_bool`
- `set_vector2i`
- `set_vector2`
- `set_vector3i`
- `set_vector3`
- `set_color`
- `set_reference`
- `set_resource`

Here's how you'd adapt the sword's damage:

```gdscript
func _ready() -> void:
   var sword = Pandora.get_entity(EntityIds.SWORD) # PandoraEntity type
   var sword_instance = sword.instantiate() # PandoraEntity type
   var damage = sword_instance.get_float("Damage") # float type

   sword_instance.set_float("Damage", 0.1) # Voila! Damage adjusted.
```
It is generally recommended to use `instantiate()` for any entity that can be unique in the game world with its own changing properties. If an entity may never change its properties, there is no need to instantiate it and simply use `PandoraEntity` instead in your code.

> You cannot set any value on `PandoraEntity` as it is a **read-only** type. Call `instantiate()` to create an object that you can store inside your save games!

> 💡 **Did you know?** `instantiate()` also works on custom entity types! It will automagically create an instanced version of your custom script with the same super-powers as any other ordinary instance.

Once an instance has been changed it would be also great to save that state in a save game - many games require saving and loading. Pandora provides an API to integrate loading and saving seamlessly. [Learn how to save and load with Pandora](/api/saveload.md).
