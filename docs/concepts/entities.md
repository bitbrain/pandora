# Categories and Entities

Within Pandora, data is organized and managed using **entities**. These entities are the foundational units of data, providing structure and specificity.

## Entity

Entities represent the individual data units in Pandora. They serve as the primary objects you'll interact with when defining game data. Every entity consists of a unique **ID**, a (non-unique) **Name**, a **parent category** and a **list of properties**. The addon API allows you to access all this data within GDScript.

- **Association with Categories**: Every entity must belong to a category. This ensures structured data organization, as categories define what properties an entity can have. This means that in order to create an entity, you will have to create a category first.

- **Inheritance and Property Overrides**: Entities inherit properties from their parent categories. However, an entity has the flexibility to override these inherited properties, giving developers precise control over data values.

## Category

Categories play a pivotal role by defining a set of properties that entities under them can possess.

- **Nature of Categories**: While categories lay down the blueprint for properties, they are, in essence, a special kind of entity. Categories group types of entities together with commonly defined properties. This also means that any category can have child categories and child entities and so on.

- **Inheritance Mechanism**: The hierarchical nature of Pandora means both entities and categories inherit properties from their parent categories. Any changes done to parent categories will be auto-propagated to children without the need to worry keeping things up to date manually.

- **Data Persistance**: In Pandora, data persistance is very important - once a complex structure has been setup (with potentially hundreds of different entities), changing a parent field should not just wip all the data. Instead, Pandora has "best effort" implementations to keep data. At worst, the user will be warned about potential data loss!

Understanding the dynamics between entities and categories is fundamental to efficiently using Pandora, ensuring your game data remains organized and accessible. However, standalone categories and entities won't do much.

Therefore, Pandora also introduces [the concept of properties](/concepts/properties/).