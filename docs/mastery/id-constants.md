# Generating ID Constants

> ⚠️ this functionality is still in alpha state. It is currently not possible to generate constants for categories or properties. Refer to [#61](https://github.com/bitbrain/pandora/issues/61) and [#63](https://github.com/bitbrain/pandora/issues/63) for more information.

Imagine you want to access a certain entity you defined:
```gdscript
# what is the ID for copper ore?
var copper_ore = Pandora.get_entity("???")
```
You could hover the entity inside the entity tree to figure out what its ID value might be which can be cumbersome. An altrnative approach could be to find the entity by name - also this can be dangerous as the name of an entity is **not unique**.

Pandora allows you to generate so called **ID Constants** that you can access directly in your code:

![id-constants](../assets/editor-id-constants.png)

This will generate a new file called `res://pandora/ores.gd` that looks a bit like this:
```gdscript
# Do not modify! Auto-generated file.
class_name Ores 

const COPPER_ORE = "14"
```
This allows you to do something like this:
```gdscript
var copper_ore = Pandora.get_entity(Ores.COPPER_ORE)
```
In case the item gets renamed, this code starts failing (which is good!) as you can catch issues at compilation time, rather when the code is running in the game!