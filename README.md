![logo](docs/assets/logo.svg)

[![pandora-ci](https://github.com/bitbrain/pandora/actions/workflows/pandora-ci.yml/badge.svg)](https://github.com/bitbrain/beehave/actions/workflows/pandora-ci.yml) [![](https://img.shields.io/discord/785246324793540608.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.com/invite/CKBuE5djXe)

---

**Welcome to _Pandora_, a powerful and user-friendly solution that elevates the way you manage, organize, and maintain crucial RPG elements within your Godot Engine 4.0 projects.** Say goodbye to tedious data management tasks, and harness the true potential of your RPG game with this all-in-one addon.

With this addon, you can effortlessly manage items, spells, abilities, characters, monsters, and loot tables through a unified and intuitive editor view. Whether you're working on a classic turn-based RPG or an action-packed adventure, this addon will simplify your workflow and provide a seamless experience.

**🤔 Why not simply using Godot Resource files?**

Godot Resources are an excellent choice to define data for your RPG. Especially the way you can define different data points via `@export` allows for maximum flexibility. However, for larger projects this approach has several challenges:

- changing resource files may lead to data loss (e.g. changing the type of a field or renaming it) and corresponding `.tres` files need to be fixed manually afterwards
- difficult to store unique information for specific resource instances - data is generally shared between all resources of the same type. It is possible to make data unique via `.duplicate(DUPLICATE_USE_INSTANTIATION)`, however, in that case changing the original resource will not propagate any longer to the duplicate instances.
- searching & filtering through all existing resources can be challenging: the only way to search through resources via code is by loading every single resource into memory and then filtering on certain attributes on it.

**Pandora** aims to address all these issues with its centralized approach to data management.

# Features

### 📚 Comprehensive Data Management

Centralize and manage all your RPG data in one unified editor view. Easily create, edit, and delete items, spells, abilities, characters, monsters, and loot tables.


### 🔧 Customizable and Modular

The addon's architecture allows you to extend and modify its functionality to suit your game's specific needs, making it an ideal choice for any RPG project. By default, data is stored inside .json files, however, you can implement your own data backend to store the RPG data in.


### 🧪 Tested - any functionality of this addon is covered by test automation

In order to avoid bugs creeping into the codebase, every feature is covered by unit tests.

# 📦 Installation

1. [Download for Godot 4.x](https://github.com/bitbrain/pandora/archive/refs/heads/godot-4.x.zip)
2. Unpack the `pandora` folder into your `/addons` folder within the Godot project
3. Enable this addon within the Godot settings: `Project > Project Settings > Plugins`

# 🥰 Credits

- logo designs by [@NathanHoad](https://twitter.com/nathanhoad)