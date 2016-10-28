Minecraft Modpack Builder
======================

This program will take a Repo hosted on Github in the Curse Export format ([example repo](https://github.com/Stonebound/Principium)), download it and automatically create Release Zip files for you. Currently it supports the following formats:

* CurseForge Zip
* TechicLauncher Zip
* Server Download Zip

Installation
-----

Grab the latest ```mc-modpack-builder.sh```, see how it works and customize it for your needs. Most stuff is commented, if you have a question open an issue.

Usage
-----

    ./mc-modpack-builder.sh [options]

Options:

    setup
        Create directories and download required files
    build
        Create Zip builds for Curse, Technic and Server
