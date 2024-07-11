#!/bin/bash

install_dependencies() {
    sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-rtsp nvidia-l4t-gstreamer
}

# Function to start the stream
start_stream() {
    camera=$1
    port=$2
    echo "Starting the stream..."
    # GStreamer pipeline
    pipeline="rtspsrc location=rtsp://172.25.125.18:8554/stream$camera ! rtph265depay ! h264parse ! openh264dec ! fpsdisplaysink sync=false"
    # Run the GStreamer pipeline in the background and redirect the output to /dev/null
    gst-launch-1.0 -v $pipeline > /dev/null 2>&1 &
    # Save the process ID of the pipeline
    echo $! > /tmp/gst_pipeline_$1.pid
}

# Function to stop the stream
stop_stream() {
    if [ -f /tmp/gst_pipeline_$1.pid ]; then
        echo "Stopping the stream..."
        # Kill the specific GStreamer pipeline process
        kill $(cat /tmp/gst_pipeline_$1.pid) > /dev/null 2>&1
        rm /tmp/gst_pipeline_$1.pid
    else
        echo "Stream is not running."
    fi
}

case "$2" in
    install)
        install_dependencies
        ;;
    start)
        case "$1" in
            1)
                start_stream $1
                ;;
            2)
                start_stream $1
                ;;
            3)
                start_stream $1
                ;;
            4)
                start_stream $1
                ;;
            all)
                start_stream 1
                start_stream 2
                start_stream 3
                start_stream 4
                ;;
            *)
                echo "Invalid camera ID."
                exit 1
                ;;
        esac
        ;;
    stop)
            case "$1" in
            1)
                stop_stream $1
                ;;
            2)
                stop_stream $1
                ;;
            3)
                stop_stream $1
                ;;
            4)
                stop_stream $1
                ;;
            all)
                stop_stream 1
                stop_stream 2
                stop_stream 3
                stop_stream 4
                ;;
            *)
                echo "Invalid camera ID."
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 {camera_id} {start|stop}"
        exit 1
        ;;
esac
