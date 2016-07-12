#!/bin/bash
# Minecraft Modpack builder from CurseVoice exports uploaded to Github

############################
## Change these variables ##
############################
packname=Principium
gituser=Stonebound
reponame=Principium
branch="1.10.2"
forgeversion="1.10.2-12.18.1.2011"

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

        cd $fileRoot

        echo "Starting build process"
        echo "Please enter a new version number:"
        read packversion

        # Alternatively ask for Forge version instead of as a set variable above
#       echo "Please enter the forge version:"
#       read forgeversion

        # Download Zip from github
        wget -O temp/gitpack.zip https://codeload.github.com/$gituser/$reponame/zip/$branch

        # Extracting Zip and deleting it when done
        cd temp
        unzip gitpack.zip
        rm gitpack.zip

        # Cleanup Github extras
        cd $reponame-$branch/

        ###########################################################################
        ## Add extra files in your repo, that you dont want in the release here. ##
        ###########################################################################
        rm README.md
        rm ISSUE_TEMPLATE.md
        rm .gitignore

        # Compressing files in proper Curse format
        zip -r ../pack.zip *
        cd ..
        rm -R $reponame-$branch/

        # Copy Curse Zip to builds folder and name it properly
        cp pack.zip $fileRoot/builds/Curse_$packname-$packversion.zip

        # Clear folder for pack with mods
        if [[ -f withmods ]]; then
			rm -rf withmods
            mkdir withmods
        else
            mkdir withmods
		fi

        # Download mods from Curse
        java -jar $fileRoot/extras/downloader.jar -i pack.zip -o withmods

        # Cleanup extra files
        cd withmods
        rm CurseModpackDownloader.txt
        rm modlist.html
        rm manifest.json

        # Create Technic Client Zip
        # Download universal forge jar
        # Zip up everything and exclude extra files
        mkdir bin
        wget -O extras/forge-$forgeversion-universal.jar http://files.minecraftforge.net/maven/net/minecraftforge/forge/$forgeversion/forge-$forgeversion-universal.jar
        zip -r $fileRoot/builds/Technic_$packname-$packversion.zip * -x "forge-*-installer.jar"

        # Cleanup Technic files
        rm -R bin

        # Create Server zip
        java -jar forge-*-installer.jar --installServer
        rm forge-*-installer.jar*
        mv forge-* forge_server.jar
        cp $fileRoot/extras/ServerStart.* .
        cp $fileRoot/extras/eula.txt
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

        # Download CurseModpackDownloader
        cd extras
        wget -O downloader.jar 'https://jenkins.dries007.net/job/CurseModpackDownloader/lastSuccessfulBuild/artifact/build/libs/CurseModpackDownloader-0.1.0.10.jar'

        # Download ServerStart.* and eula.txt
        wget -O ServerStart.bat 'https://cdn.rawgit.com/Stonebound/mc-modpack-builder/37ccb40cf958983953a00c204c483234880f1732/files/ServerStart.bat'
        wget -O ServerStart.sh 'https://cdn.rawgit.com/Stonebound/mc-modpack-builder/37ccb40cf958983953a00c204c483234880f1732/files/ServerStart.sh'
        wget -O eula.txt 'https://cdn.rawgit.com/Stonebound/mc-modpack-builder/37ccb40cf958983953a00c204c483234880f1732/files/eula.txt'

        echo #newline for cleanliness
        boldDisplay "Setup complete."
        exit 0
    ;;
    *)
        boldDisplay "Minecraft Modpack Builder"
        echo "Version 0.10 - Author phit <phit@hush.com>"
        echo #newline for cleanliness
        echo "Available Options:"
        echo "setup     Create directories and download required files"
        echo "build     Create Zip builds for Curse, Technic and Server"
    ;;
esac
