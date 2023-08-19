![logo](docs/assets/logo.svg)

[![pandora-ci](https://github.com/bitbrain/pandora/actions/workflows/pandora-ci.yml/badge.svg)](https://github.com/bitbrain/pandora/actions/workflows/pandora-ci.yml) [![](https://img.shields.io/discord/785246324793540608.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.com/invite/CKBuE5djXe)

---

### ⚠️ THIS ADDON [ IS STILL IN ALPHA](https://github.com/bitbrain/pandora/milestone/1) AND NOT PRODUCTION-READY YET.

**Meet _Pandora_, an addon for the Godot Engine that simplifies the handling of RPG data.** Pandora allows you to easily manage RPG elements like items, spells, abilities, characters, monsters, and loot tables. Whether you're building a traditional turn-based RPG or a fast-paced action game, this addon can help.

# Features

### 🪟 Dedicated Editor UI

Manage all your RPG data in one place. Create, edit, and delete items, spells, abilities, characters, monsters, and loot tables easily. Properties will propagate automatically to child categories and entities.

![editor-example](docs/assets/editor-example.png)

### 🔌 Accessible API

Pandora comes with an accessible API through the `Pandora` singleton. Access all your data at runtime or even within tool scripts!

```gdscript
class_name MyScene extends Node2D

# Entity can be selected in the editor
@export var entity:PandoraEntity

var instance:PandoraEntityInstance

func _ready():
   # create a new instance of this entity
   self.instance = entity.instantiate()
   instance.set_integer("Current Stack Size", 3)
   var other_entity := Pandora.get_entity(EntityIds.COPPER_ORE)
```

### 🧪 Tested

To keep the codebase clean, we cover every feature with unit tests.

# 📦 Installation

1. [Download for Godot 4.x](https://github.com/bitbrain/pandora/archive/refs/heads/godot-4.x.zip)
2. Extract the `pandora` folder into your `/addons` folder within the Godot project.
3. Activate the addon in the Godot settings: `Project > Project Settings > Plugins`

# Getting started

### [Official Wiki](https://bitbra.in/pandora)


# 🥰 Credits

- Logo designs by [@NathanHoad](https://twitter.com/nathanhoad)