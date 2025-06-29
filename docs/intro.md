---
sidebar_position: 0
---

# Installation
# Wally
Add the following dependency into your dependencies list in `wally.toml`:
```toml
[dependencies]
Val = "tumblewede/val@0.1.1"
```
Then, run `wally install` in your project's terminal to install the dependency.

:::info[Restoring Type Safety]
Unfortunately, you cannot access types from Wally packages due to the structure of Packages. To fix this, we can install [wally-package-types](https://github.com/JohnnyMorganz/wally-package-types) as a workaround.

To install [wally-package-types](https://github.com/JohnnyMorganz/wally-package-types), run the following command in your terminal:
```sh
cargo install wally-package-types
```
If your project does not have a sourcemap, then run the following command in your project's terminal:
```sh
rojo sourcemap default.project.json --output sourcemap.json
```
Finally, run the command:
```sh
wally-package-types --sourcemap sourcemap.json Packages/
```

:::
# Roblox Studio
1. Go to the [Releases page](https://github.com/TumbleWede/Val/releases) of the GitHub repository
2. Open up the Assets dropdown of the version you'd like to use (ideally the latest version)
3. Download the `Val.rbxm` file
4. Drag & drop the `Val.rbxm` into your Roblox Studio game
5. Relocate the module if needed (ideally in a libraries/modules folder in ReplicatedStorage)
# Source Code
1. Go to the [Releases page](https://github.com/TumbleWede/Val/releases) of the GitHub repository
2. Open up the Assets dropdown of the version you'd like to use (ideally the latest version)
3. Download the `Val.luau` file
4. - If you are using Rojo, then drag & drop the `Val.luau` into somewhere in your project.
   - If you are using Roblox Studio, then copy and paste the contents of `Val.luau` into a new `ModuleScript` named `Val`.