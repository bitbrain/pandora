# Property: String

The `String` property in Pandora allows you to store string values. This type of property is commonly used for descriptions, names and translation keys.

## Value Examples

Define the name of a monster.

**Configuration**:
- **Value**: `"Capra Demon"`

**GDScript Example**:

```gdscript
var monster_name = Pandora.get_entity(EntityIds.MY_ENTITY).get_string("Name")
```

## Property Settings

No settings for `String`
