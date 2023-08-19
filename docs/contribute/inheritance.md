# 👨‍👩‍👧‍👦 Property Inheritance

In order to ensure properties are inherited properly, each child automatically inherits the property objects of its parent. However, in the UI it is possible to simply override a property or also clear an override. To make this possible, Pandora introduces an [OverridingProperty](https://github.com/bitbrain/pandora/blob/godot-4.x/addons/pandora/model/entity.gd#L19) that "decorates" the parent's property. You can visualise it as follows:
```
Child Property -- overrides -> Parent Property
```
In case the value of `Parent Property` gets changed, `Child Property` will automatically know about these changes as it is pointing to it. `Child Property` can also override the value of its parent with its own value. From a UI perspective, the user will not see those two properties but only the property corresponding to the entity, e.g. they would see `Parent Property` when selecting the parent and `Child Property` when selecting the child. This code pattern is called [decorator pattern](https://en.wikipedia.org/wiki/Decorator_pattern).