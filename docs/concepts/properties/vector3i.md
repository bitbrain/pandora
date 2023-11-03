# Property: Vector3i

The `Vector3i` property in Pandora lets you store three related integers. It's useful for attributes that only have meaning when paired, such as the X, Y, and Z values of a 3D grid position.

## Value Examples

Define the grid position of an item on a 3D map.

**Configuration**:
- **Value**: `Vector3i(0, 2, 1)`

**GDScript Example**:

```gdscript
var grid_position = Pandora.get_entity(EntityIds.MY_ITEM).get_vector3i("Grid Position")
```

## Property Settings

|Setting Name|Description|Default Value|
|---|---|---|
|**Min Component Value**| Sets the lower limit of the `x`, `y`, and `z` components.| `-999999999`|
|**Max Component Value**| Sets the upper limit of the `x`, `y`, and `z` components.| `999999999`|
