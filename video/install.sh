#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

install_dependencies() {
    sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-rtsp \
        python3-gst-1.0 gstreamer1.0-python3-plugin-loader

    if [ "$TARGET" == "ORIN" ]; then
        sudo apt-get install -y nvidia-l4t-gstreamer
        $SCRIPT_DIR/video-processing/install.sh
    fi
}

install_dependencies
