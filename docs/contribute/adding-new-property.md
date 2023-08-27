# 🔌 Adding a new property

In this section you will learn how to introduce new property types to Pandora. [Refer to these docs](http://localhost:3000/#/concepts/properties/) to see a list of all currently available properties.

## Step 1: Make `PandoraProperty` aware of new type

Head to `res://addons/pandora/model/property.gd` and open up the file. The `PandoraProperty` is responsible for storing and providing property information to Godot. This type has a few responsibilities:

- define what properties are valid
- define how to load/read properties from json
- provide methods to access and update the property values via GDScript

Search for the `_type_checks()` method that defines which variants are actually valid and allowed by Pandora. Add your new type there. Make sure you choose a name for your property type that is concise and makes sense.

> `Dictionary` and `Array` may be special cases here, e.g. an `Array` may still be of type `reference` but instead of a single value, its `Variant` is an array of references.

Also ensure to define a default value if deemed necessary in this script. Further up you will find methods regarding parsing and writing data - some properties like `"color"` need to be stored somehow to JSON, which is handled there.

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

