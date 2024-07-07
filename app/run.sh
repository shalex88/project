#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$(dirname $SCRIPT_DIR)

run_web_server() {
    echo "Starting web server..."
    $PROJECT_DIR/web-server/run.sh start
    echo "Starting web server... Done!"
}

stop_web_server() {
    echo "Stopping web server..."
    $PROJECT_DIR/web-server/run.sh stop
    echo "Stopping web server... Done!"
}

run_media_server() {
    echo "Starting video server..."
    $PROJECT_DIR/media-server/run.sh
}

start_video_stream() {
    echo "Starting video server..."
    $PROJECT_DIR/video/start_stream.sh all start
    echo "Starting video server... Done!"
}

stop_video_stream() {
    echo "Stopping video server..."
    $PROJECT_DIR/video/start_stream.sh all stop
    echo "Stopping video server... Done!"
}

stop_video_stream
run_web_server
run_media_server
stop_video_stream
stop_web_server
