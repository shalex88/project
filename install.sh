#!/bin/bash -e

set_target_env() {
    target="Unknown"
    arch=$(uname -m)

    if [ -e "/proc/device-tree/model" ]; then
        model=$(tr -d '\0' < /proc/device-tree/model)
        if [[ $model == *"Orin"* ]]; then
            target="ORIN"
        fi
    fi

    echo "Running on $target $arch"
    export TARGET=$target
    export ARCH=$arch
}

install_nvidia_jetpack() {
    sudo apt update
    sudo apt install nvidia-jetpack
}

install_dependencies() {
    ./ui/web-server/install.sh
    ./video/media-server/install.sh
    ./video/install.sh
    ./app/install.sh
    if [ "$TARGET" == "ORIN" ]; then
        install_nvidia_jetpack
    fi
}

set_target_env
install_dependencies
