#!/bin/bash
#
# LH Kernel Universal Build Script for Arm64 Kernels
#
# Copyright (C) 2018 Luan Halaiko (tecnotailsplays@gmail.com)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#Colors
black='\033[0;30m'
red='\033[0;31m'
green='\033[0;32m'
brown='\033[0;33m'
blue='\033[0;34m'
purple='\033[1;35m'
cyan='\033[0;36m'
nc='\033[0m'

#Directories
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$KERNEL_DIR/Zipper
CONFIG_DIR=$KERNEL_DIR/arch/arm64/configs

#Export
export CROSS_COMPILE="$HOME/kernel/google-santoni/bin/aarch64-linux-android-"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="LuanHalaiko"
export KBUILD_BUILD_HOST="CrossBuilder"

#Out folder
mkdir -p out

#Misc
CONFIG=msm8953-perf_defconfig
THREAD="O=out -j$(grep -c ^processor /proc/cpuinfo)"
OUT="O=out"

#LH Logo
echo -e "$blue############################ WELCOME TO #############################"
echo -e "                  __                   __  __      __  __  __           "
echo -e "                 / /   /\  /\   /\ /\ /__\/__\  /\ \ \/__\/ /           "
echo -e "                / /   / /_/ /  / //_//_\ / \// /  \/ /_\ / /            "
echo -e "               / /___/ __  /  / __ \//__/ _  \/ /\  //__/ /___          "
echo -e "               \____/\/ /_/   \/  \/\__/\/ \_/\_\ \/\__/\____/          "
echo -e "                                                                        "
echo -e "\n############################# BUILDER ###############################$nc"

#Main script
while true; do
echo -e "\n$green[1]Build Kernel"
echo -e "[2]Regenerate defconfig"
echo -e "[3]Source cleanup"
echo -e "[4]Create flashable zip"
echo -e "[5]Quit$nc"
echo -ne "\n$brown(i)Please enter a choice[1-5]:$nc "

read choice

if [ "$choice" == "1" ]; then
  BUILD_START=$(date +"%s")
  DATE=`date`
  echo -e "\n$cyan#######################################################################$nc"
  echo -e "$purple(i)Build has been started at $DATE$nc"
  make $CONFIG $OUT &>/dev/null
  make $THREAD &>Buildlog.txt & pid=$!
  spin[0]="$blue-"
  spin[1]="\\"
  spin[2]="|"
  spin[3]="/$nc"

  echo -ne "$blue[Please wait...] ${spin[0]}$nc"
  while kill -0 $pid &>/dev/null
  do
    for i in "${spin[@]}"
    do
          echo -ne "\b$i"
          sleep 0.1
    done
  done
  if ! [ -a $KERN_IMG ]; then
    echo -e "\n$red(!)Kernel compilation failed, check buildlog to fix errors $nc"
    echo -e "$red#######################################################################$nc"
    exit 1
  fi
  BUILD_END=$(date +"%s")
  DIFF=$(($BUILD_END - $BUILD_START))
  echo -e "\n$brown(i)Image-dtb compiled successfully.$nc"
  echo -e "$cyan#######################################################################$nc"
  echo -e "$purple(i)Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nc"
  echo -e "$cyan#######################################################################$nc"
fi

if [ "$choice" == "2" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  make $CONFIG
  cp .config arch/arm64/configs/$CONFIG
  echo -e "$purple(i)Defconfig regenerated.$nc"
  echo -e "$cyan#######################################################################$nc"
fi

if [ "$choice" == "3" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  rm -f $DT_IMG
  make clean &>/dev/null
  make mrproper &>/dev/null
  echo -e "$purple(i)Kernel source cleaned up.$nc"
  echo -e "$cyan#######################################################################$nc"
fi


if [ "$choice" == "4" ]; then
  echo -e "\n$cyan#######################################################################$nc"
  cd $ZIP_DIR
  make clean &>/dev/null
  cp $KERN_IMG $ZIP_DIR/boot/zImage
  make &>/dev/null
  make sign &>/dev/null
  cd ..
  echo -e "$purple(i)Flashable zip generated under $ZIP_DIR.$nc"
  echo -e "$cyan#######################################################################$nc"
fi


if [ "$choice" == "5" ]; then
 exit 1
fi
done
