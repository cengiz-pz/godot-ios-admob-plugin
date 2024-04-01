___

# Godot iOS plugin template

This repository contains a *starter* Xcode and SCons configuration to build a Godot plugin for iOS.
Xcode project and Scons configuration allows to build static `.a` library, that could be used with `.gdip` file as Godot's plugin to include platform functionality into exported application.

<br/>

___

# Prerequisites

- [Install SCons](https://scons.org/doc/production/HTML/scons-user/ch01s02.html)
- [Install CocoaPods](https://guides.cocoapods.org/using/getting-started.html)

<br/>

___

# Customization

- Run `./script/init.sh <name of plugin>` to replace the template plugin name with the actual name of the plugin.

<br/>

___

# Run build

- Run `./script/build.sh -A <godot version>` initially to run a full build
- Run `./script/build.sh -cgA <godot version>` to clean, redownload Godot, and rebuild
- Run `./script/build.sh -ca` to clean and build without redownloading Godot
- Run `./script/build.sh -h` for more information on the build script

<br/>

___

# Libraries

Library archives will be created in the `bin/release` directory.
