# Property: Color

The `Color` property in Pandora is used to describe the color attributes of entities. It allows for the definition of RGBA values.

## Value Examples

Define the color of a magic potion.

**Configuration**:
- **Value**: `Color(1.0, 0.0, 0.0)` (Red)

**GDScript Example**:
```gdscript
var potion_color = Pandora.get_entity(EntityIds.MY_POTION).get_color("Potion Color")
```

## Property Settings

No settings for `Color`.