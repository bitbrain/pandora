# Generating ID Constants

> ⚠️ this functionality is still in alpha state. It is currently not possible to generate constants for properties. Refer to [#61](https://github.com/bitbrain/pandora/issues/61) for more information.

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

Pandora will also generate a PandoraCategories file that contains the Category IDs of all categories and subcategories in your tree.
It handles non-unique categories by prepending the parents name to the category class generated.

It will generate a file called `res://pandora/categories.gs` that looks a bit like this:

```gdscript
# Do not modify! Auto-generated file.
class_name PandoraCategories


const ITEMS = "3"
const RARITY = "7"
const ENCHANTMENTS = "48"
const SKILLS = "66"
const ANIMATIONS = "70"
const CHARACTERS = "71"
const BODY_TYPES = "72"
const LOOT = "73"
const HAIR_TYPES = "120"
const RESOURCES = "135"
const RESOURCE_STATES = "142"
const GAMECONFIG = "177"


class ItemsCategories:
	const EQUIPMENT = "4"
	const CONSUMABLE = "37"
	const RESOURCE = "38"
	const LITERARY = "39"
	const QUESTS = "40"
	const MISC = "41"


class EquipmentCategories:
	const WIELD = "35"
	const ARMOR = "50"
	const ACCESSORIES = "51"

```

This allows you to do something like this:

```gdscript
if entity.is_category(ItemsCategories.EQUIPMENT):
   # entity is under the Equipment category
```
