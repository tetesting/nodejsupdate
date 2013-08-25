#!/bin/bash

curdir=`pwd`
tempdir=~/node_tmp_`date +%Y%m%d%H%M%S`
mkdir $tempdir
cd $tempdir

wget http://nodejs.org/download/
# retrieve version number and confirm update
version_num=`egrep 'Current version:' index.html | cut -d'v' -f3 | cut -d'<' -f1`
echo "The latest version is: $version_num"
if test `which node | wc -l` -gt 0 ; then
    echo "You currently have `node -v` installed."
    while true ; do
        read -p "Upgrade? [y/n] " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) 
                cd $curdir
                rm -rf $tempdir 
                exit;;
            * ) echo "Please answer y or n";;
        esac
    done
fi

# offer to choose platform
# TODO: autodetect the platform
chosen=0;
printf "\nAvailable platforms:\n"
echo "1: Linux    - 32-bit"
echo "2: Linux    - 64-bit"
echo "3: Mac OS X - 32-bit"
echo "4: Mac OS X - 64-bit"
printf "\nq: Cancel installation\n"
read -p "For which platform would you like to install node onto? " choice
while test $chosen = 0 ; do
    case $choice in
        [1]* )
          platform=linux-x86
          chosen=1
          break;;
        [2]* )
          platform=linux-x64
          chosen=1
          break;;
        [3]* )
          platform=darwin-x86
          chosen=1
          break;;
        [4]* )
          platform=darwin-x64
          chosen=1
          break;;
        [Qq]* ) 
            cd $curdir
            rm -rf $tempdir 
            exit;;
        * )
            echo "Available platforms:"
            echo "1: Linux    - 32-bit"
            echo "2: Linux    - 64-bit"
            echo "3: Mac OS X - 32-bit"
            echo "4: Mac OS X - 64-bit"
            printf "\nq: Cancel installation\n"
            read -p "Please try again: " choice;;
    esac
done


# retrieve latest nodejs binary for chosen platform
archive_url=`egrep "$platform.tar.gz" index.html | cut -d'"' -f2`
wget $archive_url
archive=`echo $archive_url | cut -d'/' -f6`


# extract archive
echo `date +'%F %T'` > nodejsextract.log
echo "Extracting archive..."
tar -xzvf $archive >> nodejsextract.log
dirname=`echo $archive | awk -F'.tar.gz' '{ print $1 }'`
mv nodejsextract.log $dirname


# create local installation directories
if ! test -d ~/.local ; then
    mkdir ~/.local
fi
if ! test -d ~/.local/bin ; then
    mkdir ~/.local/bin
fi


# delete previous versions of node
rm -rf ~/.local/node*$platform
echo "Moving files into ~/.local/ ..."
mv $dirname ~/.local


echo "Adding binaries to user's path..."

# add $HOME/.local/bin to $PATH
if test `grep "\.local/bin" ~/.bash_profile -c` = 0 ; then
    printf '\nPATH=$HOME/.local/bin:$PATH\n' >> ~/.bash_profile
    PATH=$HOME/.local/bin:$PATH
    echo "Added $HOME/.local/bin to PATH..."
fi

# add node_modules to $PATH
if test `grep "node_modules/\.bin" ~/.bash_profile -c` = 0 ; then
    printf '\n# node_modules to $PATH\n' >> ~/.bash_profile
    printf 'PATH=$HOME/node_modules/.bin:$PATH\n' >> ~/.bash_profile
    PATH=$HOME/node_modules/.bin:$PATH
    echo "Added $HOME/node_modules/.bin to PATH..."
fi


# create symlinks to binaries
echo "Creating necessary symlinks..."
if test -h ~/.local/bin/node ; then
    rm ~/.local/bin/node
fi
if test -h ~/.local/bin/npm ; then
    rm ~/.local/bin/npm
fi
ln -s $HOME/.local/$dirname/bin/node ~/.local/bin/node
ln -s $HOME/.local/$dirname/bin/npm ~/.local/bin/npm


# clean up
cd $curdir
rm -rf $tempdir

echo "Installation script ended."
echo "You will need to reboot to have the binary directories permanenetly added to your PATH."
