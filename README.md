Minecraft Modpack Builder
======================

This program will take a Repo hosted on Github in the Curse Export format ([example repo](https://github.com/Stonebound/Principium)), download it and automatically create Release Zip files for you. Currently it supports the following formats:

* CurseForge Zip
* TechicLauncher Zip
* Server Download Zip

Installation
-----

Grab the latest version from the Release section and make it executable with
```
wget https://raw.githubusercontent.com/Stonebound/mc-modpack-builder/master/mc-modpack-builder.sh
chmod +x mc-modpack-builder.sh
```
then edit the script and change the variables at the top for your needs. If you have clientside only mods in your pack add them [here](https://github.com/Stonebound/mc-modpack-builder/blob/master/mc-modpack-builder.sh#L102).

Usage
-----

    ./mc-modpack-builder.sh [options]

Options:

    setup
        Create directories and download required files
    build
        Create Zip builds for Curse, Technic and Server

License
-------

Minecraft Modpack Builder

Copyright (C) 2016 phit

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
