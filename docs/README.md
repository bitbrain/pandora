![logo](assets/logo.svg)

[![pandora-ci](https://github.com/bitbrain/pandora/actions/workflows/pandora-ci.yml/badge.svg)](https://github.com/bitbrain/pandora/actions/workflows/pandora-ci.yml) [![](https://img.shields.io/discord/785246324793540608.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.com/invite/CKBuE5djXe)

---

**Meet _Pandora_, an addon for the Godot Engine that simplifies the handling of RPG data.** Pandora allows you to easily manage RPG elements like items, spells, abilities, characters, monsters, and loot tables. Whether you're building a traditional turn-based RPG or a fast-paced action game, this addon can help.

**🤔 Why Pandora over Godot Resource files?**

Godot Resources are great for defining RPG data, but they can be challenging to manage, especially for larger projects:

- Modifying resource files might cause data loss (like changing a field's type or name). This requires fixing associated `.tres` files manually.
- Storing unique data for specific resource instances is difficult.
- Searching through resources can be a challenge. Currently, the only way to search through resources in the code is by loading each resource into memory.

**Pandora** solves these problems with a centralized approach to data management.

# Features

### 📚 Centralized data management

Manage all your RPG data in one place. Create, edit, and delete items, spells, abilities, characters, monsters, and loot tables easily. Access all data directly in the code via the `Pandora` API.

### 🔧 Customizable and Modular

Adjust Pandora to fit your game's needs. By default, data is stored in .json files, but you can implement your own data backend.

### 🧪 Tested

To keep the codebase clean, we cover every feature with unit tests.

# 📦 Installation

1. [Download for Godot 4.x](https://github.com/bitbrain/pandora/archive/refs/heads/godot-4.x.zip)
2. Extract the `pandora` folder into your `/addons` folder within the Godot project.
3. Activate the addon in the Godot settings: `Project > Project Settings > Plugins`


# 🐲 Create your first entity!


# 🥰 Credits

- Logo designs by [@NathanHoad](https://twitter.com/nathanhoad)