# 🔌 Adding a new property

In this section you will learn how to introduce new property types to Pandora. [Refer to these docs](http://localhost:3000/#/concepts/properties/) to see a list of all currently available properties.

## Step 1: Add new subclass of `PandoraPropertyType`

Head to `res://addons/pandora/model/types` and create a new script with the name of your type that extends `PandoraPropertyType`:
```gdscript
extends PandoraPropertyType

const SETTINGS = {}


func _init() -> void:
   super("identifier", SETTINGS, null)
```
The parent `_init()` function takes the following parameters:

- the `name` of a type, e.g. `"identifier"` with which the type is identified across Pandora
- the `settings` this type provides - this is especially useful if you want to make this type customizable
- the `default` value that this type provides, in case the user does not specify one.

### Validation

Ensure to override the `is_valid(variant:Variant)` method to ensure variants used in combination with this type are valid, e.g.:
```gdscript
func is_valid(variant:Variant) -> bool:
   # ensures only arrays are supported
   return variant is Array
```

### Parsing & Saving

Some types require custom parsing - e.g. inside Pandora, the `"color"` type variant is of type `Color` - however, it gets stored as its HTML representation to disk. Override the `parse_value` (reading from file) and `write_value` (writing to file) functions to customise serialization.

## Step 2: Build Property Picker Component

Before we can add a button to the UI that adds a new property to a category, we have to build the component that lets us "set" and "view" the property. You can find an existing list of such components in `res://addons/pandora/ui/components/properties`.

Add a new folder with the name of your property, create both `.tscn` and `.gd` files and make sure it extends `PandoraPropertyControl`. The important methods here are the following:

 - `_ready()` make sure to connect any required signals here that will update the `_property` variable accessible in the code (coming from the parent `PandoraPropertyControl`)
 - `refresh()` ensure the UI is initialised with the current `_property` value. Study the existing components for examples how this is done.

Most importantly, head to the `.tscn` file and ensure the `Type` property is set to the name of your new property. Otherwise Pandora will not be able to associate it correctly!

## Step 3: Add Button to Property Bar

Next we need to somehow tell Pandora to create properties of our new type. Open `res://addons/pandora/ui/components/property_bar/property_bar.tscn` and add a new `PandoraPropertyButton` to it. Then, head to its `Scene` property and assign the previously created component from **Step 2** to it.

Also make sure to pick a good icon for your property. It needs to be a `16x16` .svg with editor scaling enabled in its import setting!

## Voila

Your new property is ready to be used!

