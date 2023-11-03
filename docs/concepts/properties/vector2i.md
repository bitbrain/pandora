# Property: Vector2i

The `Vector2i` property in Pandora lets you store a related pair of integers. It's useful for attributes that only have meaning when paired, such as the X and Y values of a 2D grid position.

## Value Examples

Define the grid position of an item on a 2D map.

**Configuration**:
- **Value**: `Vector2i(0, 2)`

**GDScript Example**:

```gdscript
var grid_position = Pandora.get_entity(EntityIds.MY_ITEM).get_vector2i("Grid Position")
```

## Property Settings

|Setting Name|Description|Default Value|
|---|---|---|
|**Min Component Value**| Sets the lower limit of the `x` and `y` components.| `-999999999`|
|**Max Component Value**| Sets the upper limit of the `x` and `y` components.| `999999999`|
