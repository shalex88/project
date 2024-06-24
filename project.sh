#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

run_web_server() {
    echo "Starting web server..."
    $SCRIPT_DIR/web-server/run.sh
    echo "Starting web server... Done!"
}

stop_web_server() {
    echo "Stopping web server..."
    sudo systemctl stop nginx
    echo "Stopping web server... Done!"
}

run_media_server() {
    echo "Starting video server..."
    $SCRIPT_DIR/media-server/run_mediamtx.sh
}

start_video_stream() {
    echo "Starting video server..."
    $SCRIPT_DIR/video/start_stream.sh all start
    echo "Starting video server... Done!"
}

stop_video_stream() {
    echo "Stopping video server..."
    $SCRIPT_DIR/video/start_stream.sh all stop
    echo "Stopping video server... Done!"
}

run_web_server
run_media_server
stop_video_stream
stop_web_server
