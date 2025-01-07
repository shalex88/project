#!/bin/bash

usage() {
    echo "usage: $(basename "$0") [CAMERA_ID] [RUN] [IP]"
    echo "CAMERA_ID <1|2|..|all> - template project language"
    echo "RUN <start|stop> - template project language"
    echo "IP - target ip address"
    echo "example:"
    echo "./$(basename "$0") all start 172.25.125.18"
    echo "./$(basename "$0") all stop"
}

install_dependencies() {
    sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-rtsp nvidia-l4t-gstreamer
}

# Function to start the stream
start_stream() {
    camera=$1
    echo "Starting the stream..."
    #TODO: Change the pipeline to match your camera settings and receive camera ID as an argument
    swh264decoding="rtph264depay ! h264parse config-interval=-1 ! openh264dec"
    swh265decoding="rtph265depay ! h265parse config-interval=-1 ! libde265dec"
    nvh264decoding="rtph264depay ! h264parse config-interval=-1 ! nvv4l2decoder ! autovideoconvert"
    nvh265decoding="rtph265depay ! h265parse config-interval=-1 ! nvv4l2decoder ! autovideoconvert"
    decoder=$swh264decoding
    pipeline="rtspsrc location=rtsp://$ip:8554/stream$camera ! $decoder ! fpsdisplaysink sync=false"
    # Run the GStreamer pipeline in the background and redirect the output to /dev/null
    gst-launch-1.0 -v $pipeline > /dev/null &
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
        ip=$3
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
        usage
        exit 1
        ;;
esac
