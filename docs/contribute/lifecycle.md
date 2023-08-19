# 🔁 Lifecycle Addon State

Pandora is loaded in a very specific way to ensure that the `Pandora` autoload is accessible in any `_ready()` function of any node:

1. Register API Autoload
2. Register Editor
3. Register Inspector Plugin
4. Load Pandora data