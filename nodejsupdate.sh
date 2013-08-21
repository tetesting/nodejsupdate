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
echo "Installing node version $version_num..."


# retrieve latest nodejs binary for linux 64-bit
archive_url=`egrep 'linux-x64.tar.gz' index.html | cut -d'"' -f2`
wget $archive_url
archive=`echo $archive_url | cut -d'/' -f6`

# extract archive
echo `date +'%F %T'` > nodejsextract.log
tar -xzvf $archive >> nodejsextract.log
dirname=`echo $archive | awk -F'.tar.gz' '{ print $1 }'`
mv nodejsextract.log $dirname

# create .local directory in the user's home dir
if ! test -d ~/.local ; then
    mkdir ~/.local
else # delete previous versions of node
    rm -rf ~/.local/node*linux-x64
fi

mv $dirname ~/.local

# create .local/bin directory in the user's home dir
if ! test -d ~/.local/bin ; then
    mkdir ~/.local/bin
fi

# add $HOME/.local/bin to $PATH
if test `grep .local/bin ~/.bash_profile  -c` = 0 ; then
    printf '\nPATH=$HOME/.local/bin:$PATH\n' >> ~/.bash_profile
fi

# add node_modules to $PATH
if test `grep .local/bin ~/.bash_profile  -c` = 0 ; then
    printf '\n# node_modules to $PATH\n' >> ~/.bash_profile
    printf '\nPATH=$HOME/node_modules/.bin:$PATH\n' >> ~/.bash_profile
fi

# create symlinks
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

