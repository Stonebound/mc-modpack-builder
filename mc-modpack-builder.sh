#!/bin/bash
# Minecraft Modpack builder from CurseVoice exports uploaded to Github

############################
## Change these variables ##
############################
packname=Principium
gituser=Stonebound
reponame=Principium
branch="1.10.2"
forgeversion="1.10.2-12.18.1.2026"

## Extra variables
fileRoot=$HOME/mcmodpackbuilder

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
#        echo ""
#        read forgeversion

        # Update from Github
        cd $reponame-$branch/
        git fetch --all
        git reset --hard origin/$branch
        git pull origin $branch

        # Compressing files in proper Curse format
        zip -r $fileRoot/builds/Curse_$packname-$packversion.zip * -x "mods/*" -x ".gitignore" -x "ISSUE_TEMPLATE.md" -x "README.md"
        cd ..

        # Clear folder for pack with mods
        rm -R $fileRoot/temp/withmods
        mkdir $fileRoot/temp/withmods

        # Copy files from git folder
        cd $fileRoot/temp/withmods
        cp -R $fileRoot/temp/$reponame-$branch/mods .
        cp -R $fileRoot/temp/$reponame-$branch/overrides/config .

        # Create Technic Client Zip
        # Download universal forge jar
        # Zip up everything and exclude extra files
        mkdir bin
        wget -O bin/modpack.jar http://files.minecraftforge.net/maven/net/minecraftforge/forge/$forgeversion/forge-$forgeversion-universal.jar
        zip -r $fileRoot/builds/Technic_$packname-$packversion.zip *

        # Cleanup Technic files
        rm -R bin

        # Create Client zip
        wget -O forge-$forgeversion-installer.jar http://files.minecraftforge.net/maven/net/minecraftforge/forge/$forgeversion/forge-$forgeversion-installer.jar
        zip -r $fileRoot/builds/Client_$packname-$packversion.zip *

        # Create MultiMC zip
        mv forge-$forgeversion-installer.jar ../
        cp -R $fileRoot/extras/MultiMC/* .
        mkdir minecraft
        mv mods minecraft/mods
        mv config minecraft/config
        sed -i -- 's/ [0-9].[0-9].[0-9]/ ${packversion}/g' instance.cfg
        cd ..
        mv withmods "Principium ${packversion}"
        zip -r $fileRoot/builds/MultiMC_$packname-$packversion.zip "Principium ${packversion}"
        mv "Principium ${packversion}" withmods
        cd withmods
        mv minecraft/mods .
        mv minecraft/config .
        rm -R minecraft
        rm -R patches
        rm .packignore
        rm instance.cfg
        mv ../forge-$forgeversion-installer.jar .

        # Create Server zip
        java -jar forge-*-installer.jar --installServer
        rm forge-*-installer.jar*
        mv forge-* forge_server.jar
        cp $fileRoot/extras/ServerStart.* .
        cp $fileRoot/extras/eula.txt .
        # Delete client side mods

        #################################
        ### ADD CLIENT SIDE MODS HERE ###
        #################################
        rm mods/ResourceLoader-*
        rm mods/BetterFoliage*
        rm mods/ChiselsBytes*
        rm mods/itemscroller*
        rm mods/MineMenu*
        rm mods/moreoverlays*
        rm mods/Neat*

        zip -r $fileRoot/builds/Server_$packname-$packversion.zip *

        # we are done!
        boldDisplay "Build complete."
        exit 0
    ;;
    setup)
        boldDisplay "Only run this once, this will wipe your current existing builds!"

        # Wipe the file directory
        read -p "Wipe your file directory now? [y/n]" -n 1 -r
        # Just quit out if they didn't say yes
        if ! [[ $REPLY =~ ^[Yy] ]]; then exit 0; fi

        # Only remove the directory if it exists
        if [[ -f $fileRoot ]]; then
            rm -rf $fileRoot
        fi

        # Recreate directories
        mkdir $fileRoot
        cd $fileRoot
        mkdir -p {temp,builds,extras}

        # Clone Repo from Github
        cd temp
        git clone -b $branch https://github.com/Stonebound/$reponame.git $reponame-$branch
        
        ## Download extra files
        cd extras
        

        # done
        echo #newline for cleanliness
        boldDisplay "Setup complete."
        exit 0
    ;;
    *)
        boldDisplay "Minecraft Modpack Builder"
        echo "Version 0.18 - Author phit <phit@hush.com>"
        echo #newline for cleanliness
        echo "Available Options:"
        echo "setup     Create directories and download required files"
        echo "build     Create Zip builds for Curse, Technic and Server"
    ;;
esac
