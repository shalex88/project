#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$(dirname $SCRIPT_DIR)

set_target_env() {
    target="Unknown"
    arch=$(uname -m)

    if [ -e "/proc/device-tree/model" ]; then
        model=$(tr -d '\0' < /proc/device-tree/model)
        if [[ $model == *"Orin"* ]]; then
            target="ORIN"
            arch=arm64
        fi
    fi

    echo "Running on $target $arch"
    export TARGET=$target
    export ARCH=$arch
}

system_configure() {
    if [ "$TARGET" == "ORIN" ]; then
        sudo nvpmodel -m 0
        sudo jetson_clocks
    fi
}

clean() {
    stop_video_stream
    stop_web_server
}

run_web_server() {
    echo "Starting web server..."
    $PROJECT_DIR/ui/web-server/run.sh start
    echo "Starting web server... Done!"
}

stop_web_server() {
    echo "Stopping web server..."
    $PROJECT_DIR/ui/web-server/run.sh stop
    echo "Stopping web server... Done!"
}

run_media_server() {
    echo "Starting video server..."
    $PROJECT_DIR/video/media-server/run.sh
}

start_video_stream() {
    echo "Starting video streams..."
    $PROJECT_DIR/video/start_stream.sh all start
    echo "Starting video streams... Done!"
}

stop_video_stream() {
    echo "Stopping video streams..."
    $PROJECT_DIR/video/start_stream.sh all stop
    echo "Stopping video streams... Done!"
}

set_target_env
system_configure
clean

run_web_server
run_media_server

clean
