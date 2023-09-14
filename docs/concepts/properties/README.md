# Properties

Properties form the attributes or details of entities, allowing them to be distinct and varied. In Pandora, properties are a modular unit, designed for maximum flexibility and reusability.

## Overview

- **Modularity**: Properties in Pandora are distinct from categories and entities in terms of their modeling. This design choice ensures that properties can be reused across different entities without redundancy.

- **Default Value**: By design, each property has a 'default value'. This captures the entity's original, unaltered state. To modify these values during gameplay, instances of entities are created. For a deeper dive into this process, see [Entity Instancing](api/instancing).

- **Unique Identification**: Every property is uniquely identifiable by an **ID**. Additionally, they have a name, or key, which is paired with a `Variant` default value. This ensures clear identification and access.

- **Types of Properties**: The power of Pandora lies in its flexibility. It supports a wide array of property types, enabling developers to define virtually any aspect of their game world.

Getting acquainted with how properties function in Pandora is crucial to defining detailed and rich game entities.

## Supported Properties

The following property types are supported:

|Pandora Type|Godot Type|
|---|---|
|[String](/concepts/properties/string.md)|`String`|
|[Integer](/concepts/properties/integer.md)|`int`|
|[Float](/concepts/properties/float.md)|`float`|
|[Bool](/concepts/properties/bool.md)|`bool`|
|[Color](/concepts/properties/color.md)|`Color`|
|[Reference](/concepts/properties/reference.md)|`PandoraEntity`|
|[Resource](/concepts/properties/resource.md)|`Resource`|
|[Array](/concepts/properties/array.md)|`Array`|

## Contribute

[Refer to this link](https://github.com/bitbrain/pandora/issues?q=is%3Aissue+label%3A%22%F0%9F%94%8C+property%22+is%3Aopen) for a complete list of open issues related to properties.