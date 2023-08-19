# Property: Reference

The `Reference` property allows linking between entities. It's instrumental when setting up relations between different game elements.

## Value Examples

Reference a particular weapon that an NPC uses.

**Configuration**:
- **Value**: Entity: "Sword of Flames"

**GDScript Example**:
```gdscript
var npc_weapon = Pandora.get_entity(EntityIds.NPC).get_reference("Weapon")
```

## Property Settings

|Setting Name|Description|Default Value|
|---|---|---|
|**Category Filter**|You can restrict the references to a particular category.|`null`|
|**List Categories**|Allows populating the reference list with categories instead of entities.|`false`|
|**Sort**|Defines how results are getting sorted.|`As-Is`|
