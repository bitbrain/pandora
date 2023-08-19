# 🏗️ Architecture

```
+---------------------+   +---------------------+   +-------------------+  
|     DataStorage    |___|     Pandora API      |___|  Pandora Editor   |
|        (JSON)       |   |   (autoload facade) |   |                   |
+---------------------+   +---------------------+   +-------------------+
                                    |
                                    v
                          +---------------------+
                          |   EntityBackend     |
                          |    (CRUD ops)       |
                          +---------------------+
                                    |
                                    v
                          +---------------------+
                          |    ID Generator     |
                          +---------------------+

```
The [Pandora API Autoload](https://github.com/bitbrain/pandora/blob/godot-4.x/addons/pandora/api.gd) is responsible for providing addon functionality to anywhere into GDScript via its `Pandora` autoload singleton.

The [EntityBackend](https://github.com/bitbrain/pandora/blob/godot-4.x/addons/pandora/backend/entity_backend.gd) is an effective CRUD (Create-Read-Update-Delete) service with additional logic to propagate properties into child categories and entities.

Every entity and property requires a unique ID. Pandora uses an [IdGenerator](https://github.com/bitbrain/pandora/blob/godot-4.x/addons/pandora/util/id_generator.gd) to generate unique ids. Since the ids are auto-incremented, they need to be persisted with the `data.pandora` file to ensure ids keep incrementing even after engine restart.

The [JsonDataStorage](https://github.com/bitbrain/pandora/blob/godot-4.x/addons/pandora/storage/json/json_data_storage.gd) is responsible for reading and writing data.

The [Pandora Editor](https://github.com/bitbrain/pandora/blob/godot-4.x/addons/pandora/ui/editor/pandora_editor.gd) initializes itself with all the data and connects itself to relevant signals available on `PandoraEntity` and `PandoraProperty`.