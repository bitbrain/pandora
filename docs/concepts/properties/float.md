# Property: Float

The `Float` property in Pandora lets you store decimal numbers. It's useful for attributes that require precision, like distances, weights, or percentages.

## Value Examples

Define the weight of a game item.

**Configuration**:
- **Value**: `10.5`

**GDScript Example**:

```gdscript
var item_weight = Pandora.get_entity(EntityIds.MY_ITEM).get_float("Item Weight")
```

## Property Settings

|Setting Name|Description|Default Value|
|---|---|---|
|**Min Value**| Sets the lower limit.| `-9999999`|
|**Max Value**| Sets the upper limit.| `9999999`|
|**Steps**| Determine the number of decimal points.| `2`|