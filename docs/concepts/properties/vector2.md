# Property: Vector2

The `Vector2` property in Pandora lets you store a related pair of float values. It's useful for attributes that only have meaning when paired, such as the X and Y values of a 2D position.

## Value Examples

Define the 2D position of an item in a level.

**Configuration**:
- **Value**: `Vector2(0.5, 12.5)`

**GDScript Example**:

```gdscript
var level_position = Pandora.get_entity(EntityIds.MY_ITEM).get_vector2("Level Position")
```

## Property Settings

|Setting Name|Description|Default Value|
|---|---|---|
|**Min Component Value**| Sets the lower limit of the `x` and `y` components.| `-999999999`|
|**Max Component Value**| Sets the upper limit of the `x` and `y` components.| `999999999`|
|**Steps**| Determine the number of decimal points.| `2`|
