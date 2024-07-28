#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

install_deepstream() {
    if ! command -v "deepstream-app" &> /dev/null; then
        file="deepstream-7.0_7.0.0-1_$ARCH.deb"
        wget --content-disposition "https://api.ngc.nvidia.com/v2/resources/org/nvidia/deepstream/7.0/files?redirect=true&path=$file" -O $file
        sudo apt install -y ./$file
        rm -rf $file
        cd /opt/nvidia/deepstream/deepstream/sources
        sudo git clone https://github.com/NVIDIA-AI-IOT/deepstream_python_apps.git -b v1.1.11
        git config --global --add safe.directory /opt/nvidia/deepstream/deepstream/sources/deepstream_python_apps
    fi
}

install_dependencies() {
    sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-rtsp \
        python3-gst-1.0 gstreamer1.0-python3-plugin-loader

    if [ "$TARGET" == "ORIN" ]; then
        sudo apt-get install -y nvidia-l4t-gstreamer
        $SCRIPT_DIR/video-processing/install.sh
        install_deepstream
    fi
}

install_dependencies
