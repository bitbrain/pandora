# Property: Resource

The `Resource` property in Pandora is utilized to incorporate any Godot resource, whether it's scenes, scripts, textures, audio, or other assets. It bridges the game's data structures with Godot's in-built resources.

## Value Examples

Attach a specific character model to an NPC.

**Configuration**:
- **Value**: Resource: `"knight_model.tscn"`

**GDScript Example**:
```gdscript
var npc_model = Pandora.get_entity(EntityIds.NPC).get_resource("Knight Model") as PackedScene
```

## Property Settings

No additional settings for `Resource`
