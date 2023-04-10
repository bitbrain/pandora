# 🍻 Contributing to this project

In case you want to suggest improvements to this addon or fix issues, feel free to raise a pull request or [raise an issue](https://github.com/bitbrain/pandora/issues)!

## 🧪 Unit testing

This project is using [gdUnit](https://github.com/MikeSchulze/gdUnit4) to ensure code quality. Every pull request that introduces new changes such as nodes or additional methods has to also provide some unit tests inside the `test/` folder. Ensure that your test is in the correct folder:

- `test/` contains generic tests for pandora

You can run the unit tests by right-clicking the `test` folder and selecting `Run tests`.

## 💎 Adding a new features

In case you want to introduce new functionality, feel free to [raise a pull request](https://github.com/bitbrain/pandora/compare). Check the issues tab for any discussions on new features, as it is a great place to gather feedback before you spend time on implementing it. Ensure to follow the official color scheme when adding new icons for nodes:

- Primary Gold: `#FFB900`
- Secondary Brown: `#8c521d`
- Treasure Green: `#228D19`
- Mystery Blue: `#2C5676`

Also ensure to update the `README.md` file with the documentation of the newly introduced feature.

## 📚 Adding documentation

When introducing a new feature or changing behavior, ensure to update this wiki accordingly. In order to do so, modify the `/docs` folder inside the repository. Run the following command in order to test your wiki locally:
```bash
docsify serve /docs
```
> 💡 [Learn more](https://docsify.js.org/#/?id=docsify) about how to use **docsify**.

## Version management

The current `godot-4.x` branch is aimed for **Godot 4.x**. When raising pull requests, make sure to also raise a Godot 4 relevant version against `godot-4.x` if requested.
