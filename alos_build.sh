#!/usr/bin/env bash
PWD=$(pwd)
pkgs=$(cat $PWD/pkgs.list)
aurpkgs=$(cat $PWD/aurpkgs.list)
work_dir="$PWD/repo"
repo="$PWD/alfheimrepo"

mkdir $work_dir
mkdir $repo

echo "Cleaning the repo directories..."
rm -rf $work_dir/*
rm -rf $repo/*

echo "Building  packages from the Arch Reposiories"
for p in $pkgs;
do
    cd $work_dir
    echo "Getting PKGBUILD :: $p ..."
    wget https://gitlab.archlinux.org/archlinux/packaging/packages/$p/-/archive/main/$p-main.tar.gz
    tar xvzf $p-main.tar.gz
    cd $p-main/
    echo "Building package :: $p ..."
    makepkg -sc --sign
    echo "moving package :: $p ..."
    cp *.pkg.tar.zst $repo/.
    cp *.pkg.tar.zst.sig $repo/.
    cd $PWD
done

echo "Building packages from the AUR Repositories"
for a in $aurpkgs;
do
    cd $work_dir
    echo "Getting PKGBUILD :: $a ..."
    git clone https://aur.archlinux.org/$a.git
    cd $a
    echo "Building package :: $a ..."
    makepkg -sc --sign
    echo "Moving package :: $a ..."
    cp *.pkg.tar.zst $repo/.
    cp *.pkg.tar.zst.sig $repo/.
    cd $PWD
done

cd $repo
echo "Building Repo Database ..."
repo-add --verify --sign $repo/apf.db.tar.gz *pkg.tar.zst
