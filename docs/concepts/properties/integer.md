# Property: Integer

The `Int` property in Pandora is used to store whole numbers. It's perfect for quantities, counts, or any numeric value that doesn't require fractions.

## Value Examples

Define the quantity of arrows in a quiver.

**Configuration**:
- **Value**: `20`

**GDScript Example**:
```gdscript
var arrow_count = Pandora.get_entity(EntityIds.MY_QUIVER).get_int("Arrow Count")
```

## Property Settings

|Setting Name|Description|Default Value|
|---|---|---|
|**Min Value**| Sets the lower limit.| `-9999999`|
|**Max Value**| Sets the upper limit.| `9999999`|