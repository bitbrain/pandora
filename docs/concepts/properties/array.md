# Property: Array

The `Array` property in Pandora allows you to store an ordered collection of items. This property can hold various types of data: integer, string, float, bool, color, reference, or resource. It's ideal for holding lists of attributes like inventory items, player statistics, or color palettes.

## Value Examples

Define a list of inventory items by reference.

**Configuration**:
- **Value**: `[Entity: "Shield", Entity: "Sword"]`

**GDScript Example**:

```gdscript
var inventory_items = Pandora.get_entity(EntityIds.MAIN_CHARACTER).get_array("Inventory Items")
```

## Property Settings

|Setting Name|Description|Default Value|
|---|---|---|
|**Array Type**| Specifies the type of the array. See below for the list of supported types| `string`|

## Supported Array Types

|Pandora Type|Godot Type|
|---|---|
|[String](/concepts/properties/string.md)|`String`|
|[Integer](/concepts/properties/integer.md)|`int`|
|[Float](/concepts/properties/float.md)|`float`|
|[Bool](/concepts/properties/bool.md)|`bool`|
|[Color](/concepts/properties/color.md)|`Color`|
|[Reference](/concepts/properties/reference.md)|`PandoraEntity`|
|[Resource](/concepts/properties/resource.md)|`Resource`|