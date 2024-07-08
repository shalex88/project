#!/bin/bash -e

install_nvidia_jetpack() {
    sudo apt update
    sudo apt install nvidia-jetpack
}

install_dependencies() {
    ./ui/web-server/install.sh
    ./video/media-server/install.sh
    ./video/install.sh
    ./app/install.sh
    ./video/video-processing/install.sh
    install_nvidia_jetpack
}

install_dependencies
