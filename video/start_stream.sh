#!/bin/bash

usage()
{
    echo "usage: $(basename "$0") [CAMERA_ID] [RUN] [PREPROCESSING] [POSTPROCESSING]"
    echo "CAMERA_ID <1|2|..|all> - template project language"
    echo "RUN <start|stop> - template project language"
    echo "PREPROCESSING <true|false> - custom preprocessing element"
    echo "POSTPROCESSING <true|false> - custom postprocessing element"
    echo "example:"
    echo "./start-stream all start true true"
    echo "./start-stream all stop"
}

# Function to start the stream
start_stream() {
    export GST_PLUGIN_PATH="/home/$USER/project/video-processing"
    camera=$1
    if [ "$2" = "true" ]; then
        preprocessing="! preprocessing"
    fi
    if [ "$3" = "true" ]; then
        postprocessing="! postprocessing"
    fi

    echo "Starting Camera$camera..."

    pipeline="videotestsrc ! video/x-raw,width=1920,height=1080,framerate=30/1,format=YUY2 ! textoverlay text="Camera$camera" $preprocessing $postprocessing ! nvvidconv ! nvv4l2h264enc ! h264parse ! rtspclientsink location=rtsp://localhost:8554/stream$camera"
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
    start)
        case "$1" in
            1)
                start_stream $1 $3 $4
                ;;
            2)
                start_stream $1 $3 $4
                ;;
            3)
                start_stream $1 $3 $4
                ;;
            4)
                start_stream $1 $3 $4
                ;;
            all)
                start_stream 1 $3 $4
                start_stream 2 $3 $4
                start_stream 3 $3 $4
                start_stream 4 $3 $4
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
