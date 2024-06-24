#!/bin/bash

install_dependencies() {
    sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-rtsp nvidia-l4t-gstreamer python3-gst-1.0 gstreamer1.0-python3-plugin-loader
}

# Function to start the stream
start_stream() {
    export GST_PLUGIN_PATH="/home/$USER/project/preprocessing"
    camera=$1
    echo "Starting the stream..."
    # GStreamer pipeline
    pipeline="videotestsrc ! video/x-raw,width=640,height=480,framerate=30/1,format=YUY2 ! textoverlay text="Camera$camera" ! custom_transform_element ! nvvidconv ! nvv4l2h264enc ! h264parse ! rtspclientsink location=rtsp://localhost:8554/stream$camera"
    # Run the GStreamer pipeline in the background and redirect the output to /dev/null
    gst-launch-1.0 -v $pipeline > /dev/null 2>&1 &
    # Save the process ID of the pipeline
    echo $! > /tmp/gst_pipeline_$1.pid
}

# Function to stop the stream
stop_stream() {
    if [ -f /tmp/gst_pipeline_$1.pid ]; then
        echo "Stopping Camera$1..."
        # Kill the specific GStreamer pipeline process
        kill $(cat /tmp/gst_pipeline_$1.pid) > /dev/null 2>&1
        rm /tmp/gst_pipeline_$1.pid
    else
        echo "Camera$1 is not running"
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
