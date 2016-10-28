#!/bin/bash
# Minecraft Modpack Builder
# Copyright (C) 2016 phit

############################
## Change these variables ##
############################

packname=packname
gituser=user
reponame=packname
branch="1.10.2"
forgeversion="1.10.2-12.18.1.2086"
fileRoot=$HOME/mcmodpackbuilder

#############################

# Display our output as bold for easy differentiation
function boldDisplay
{
    echo `tput smul`"$1"`tput rmul`
}

case "$1" in
    build)
        # Before we do anything, make sure the root folder exists
        if ! [[ -d "$fileRoot" ]]; then
            echo "Run setup first, exiting..."
            exit 0
        fi

        cd $fileRoot/temp

        echo "Starting build process"
        echo "Make sure you updated the forge version if needed in the script. You can ctrl+c now if you haven't"
        echo "Please enter a new version number:"
        read packversion

        # Alternatively ask for Forge version instead of as a set variable above
#       echo ""
#       read forgeversion

        # Update from Github
        cd $reponame-$branch/
        git fetch --all
        git reset --hard origin/$branch
        git pull origin $branch
        
        ######################################################
        ## Create Curse Client zip exluding extra git files ##
        ######################################################
        
        zip -r $fileRoot/builds/Curse_$packname-$packversion.zip * -x "mods/*" -x ".gitignore" -x "ISSUE_TEMPLATE.md" -x "README.md"
        
        cd ..

        # Clear folder for pack with mods
        rm -R $fileRoot/temp/withmods
        mkdir $fileRoot/temp/withmods

        # Copy files from git folder
        cd $fileRoot/temp/withmods
        cp -R $fileRoot/temp/$reponame-$branch/mods .
        cp -R $fileRoot/temp/$reponame-$branch/overrides/config .
        cp -R $fileRoot/temp/$reponame-$branch/overrides/resources .

        ####################################
        ## Create Technic Client zip-file ##
        ####################################
        
        # Download universal Forge jar, Technic still ships Forge witht he pack downloads
        mkdir bin
        wget -O bin/modpack.jar http://files.minecraftforge.net/maven/net/minecraftforge/forge/$forgeversion/forge-$forgeversion-universal.jar
        
        # Zip up everything
        zip -r $fileRoot/builds/Technic_$packname-$packversion.zip *

        # Cleanup extra Technic files
        rm -R bin

        ####################################
        ## Create vanilla client zip-file ##
        ####################################
        
        # Download Forge installer
        wget -O forge-$forgeversion-installer.jar http://files.minecraftforge.net/maven/net/minecraftforge/forge/$forgeversion/forge-$forgeversion-installer.jar
        
        # Zip up everything and exclude extra files
        zip -r $fileRoot/builds/Client_$packname-$packversion.zip *

        #############################
        ## Create MultiMC zip-file ##
        #############################
        
        # Move our Forge installer for later use
        mv forge-$forgeversion-installer.jar ../
        
        # Copy MultiMC files from extras folder
        cp -R $fileRoot/extras/MultiMC/* .
        mkdir minecraft
        
        # Fix folder structure
        mv mods minecraft/mods
        mv config minecraft/config
        mv resources minecraft/resources
        
        # Edit pack version
        sed -i -- 's/ [0-9].[0-9].[0-9]/ ${packversion}/g' instance.cfg

        # Rename folder since that is where MultiMC gets the pack name from
        cd ..
        mv withmods "Principium ${packversion}"
        
        # Zip everything and rename folder back after it's done
        zip -r $fileRoot/builds/MultiMC_$packname-$packversion.zip "Principium ${packversion}"
        mv "Principium ${packversion}" withmods
        
        ############################
        ## Create server zip-file ##
        ############################
        
        # Undo MultiMC folder structure
        cd withmods
        mv minecraft/mods .
        mv minecraft/config .
        mv minecraft/resources .
        rm -R minecraft
        rm -R patches
        rm .packignore
        rm instance.cfg
        
        # Get back the forge installer from earlier
        mv ../forge-$forgeversion-installer.jar .

        # Use the installer to get the server files
        java -jar forge-*-installer.jar --installServer
        rm forge-*-installer.jar*
        mv forge-* forge_server.jar
        
        # Copy extra server files to folder
        cp $fileRoot/extras/ServerStart.* .
        cp $fileRoot/extras/eula.txt .
        
        # Delete client side mods
        #################################
        ### ADD CLIENT SIDE MODS HERE ###
        #################################
        rm mods/ResourceLoader-*

        # Zip up everything
        zip -r $fileRoot/builds/Server_$packname-$packversion.zip *

        # we are done!
        boldDisplay "Build complete."
        exit 0
    ;;
    setup)
        boldDisplay "Only run this once, this will wipe your current existing builds!"

        # Wipe everything?
        read -p "Wipe your file directory now? [y/n]" -n 1 -r
        # Just quit out if they didn't say yes
        if ! [[ $REPLY =~ ^[Yy] ]]; then exit 0; fi

        # Only remove the directory if it exists
        if [[ -f $fileRoot ]]; then
            rm -rf $fileRoot
        fi

        # Create directories
        mkdir $fileRoot
        cd $fileRoot
        mkdir -p {temp,builds,extras}

        # Clone Repo from Github
        cd temp
        git clone -b $branch https://github.com/Stonebound/$reponame.git $reponame-$branch

        ## Download extra files
        ## You probably want to customize these, especially the MultiMC patches
        cd $fileRoot/extras
        wget https://raw.githubusercontent.com/Stonebound/mc-modpack-builder/master/files/ServerStart.sh
        wget https://raw.githubusercontent.com/Stonebound/mc-modpack-builder/master/files/ServerStart.bat
        wget https://raw.githubusercontent.com/Stonebound/mc-modpack-builder/master/files/eula.txt
        mkdir MultiMC
        cd MultiMC
        mkdir -p {minecraft,patches}
        wget https://raw.githubusercontent.com/Stonebound/mc-modpack-builder/master/files/MultiMC/instance.cfg
        wget https://raw.githubusercontent.com/Stonebound/mc-modpack-builder/master/files/MultiMC/.packignore
        cd patches
        wget https://raw.githubusercontent.com/Stonebound/mc-modpack-builder/master/files/MultiMC/patches/net.minecraftforge.json

        # done
        cd $fileRoot
        echo #newline for cleanliness
        boldDisplay "Setup complete."
        exit 0
    ;;
    *)
        boldDisplay "Minecraft Modpack Builder"
        echo "Author phit <phit@hush.com>"
        echo #newline for cleanliness
        echo "Available Options:"
        echo "setup     Create directories and download required files"
        echo "build     Create Zip builds for Curse, Technic and Server"
    ;;
esac
