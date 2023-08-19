# Property: Bool

The `Bool` property in Pandora allows you to store boolean values (`true` or `false`). This type of property is commonly used to define flags or toggles for entities.

## Value Examples

Define if an entity is active or not.

**Configuration**:
- **Value**: `true` (or `false`)

**GDScript Example**:

```gdscript
var is_active = Pandora.get_entity(EntityIds.MY_ENTITY).get_bool("Is Active")
```

## Property Settings

No settings for `Bool`.