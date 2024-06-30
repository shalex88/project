#!/bin/bash

install_dependencies() {
    sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-rtsp nvidia-l4t-gstreamer python3-gst-1.0 gstreamer1.0-python3-plugin-loader
}

install_dependencies
