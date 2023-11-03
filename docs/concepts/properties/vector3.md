# Property: Vector3

The `Vector3` property in Pandora lets you store three related float values. It's useful for attributes that only have meaning when paired, such as the X, Y, and Z values of 3D position.

## Value Examples

Define the 3D position of an item in a level.

**Configuration**:
- **Value**: `Vector3(0.0, 2.15, 1.5)`

**GDScript Example**:

```gdscript
var level_position = Pandora.get_entity(EntityIds.MY_ITEM).get_vector3("Level Position")
```

## Property Settings

|Setting Name|Description|Default Value|
|---|---|---|
|**Min Component Value**| Sets the lower limit of the `x`, `y`, and `z` components.| `-999999999`|
|**Max Component Value**| Sets the upper limit of the `x`, `y`, and `z` components.| `999999999`|
|**Steps**| Determine the number of decimal points.| `2`|
