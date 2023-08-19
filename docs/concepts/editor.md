# Editor Interface

Pandora comes with an inbuilt editor directly inside Godot Engine:

![editor](../assets/editor-layout.png)

1. **Control Bar**: Create or delete entities, save the game or reset the addon to the latest save.
2. **Entity Tree**: View and Select entities and categories.
3. **Property Bar**: Create a new property on the currently selected category.
4. **Property List**: All created properties for the currently selected category or entity. Property names can be changed only on its original category - click on the reference link to navigate to it. Values can be changed on all entities and categories. They values will be propagated down automatically. [Learn more about property inheritance here](/concepts/entities).
5. **Entity Configuration**: each entity comes with a default configuration such as its icon and the script it is instantiated with. Those can be changed on a per entity basis.
6. **Property Configuration**: selecting the name of a property will open up its configuration. Many properties support a set of configurations that can be adjusted to the user's needs. [Learn more about property attributes](/concepts/properties/)
7. **Information Bar**: learn more about how to contribute to this addon, as well as some useful links. This also contains the current addon version - ensure to include this version in any bug report!