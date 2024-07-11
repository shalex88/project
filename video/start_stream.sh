#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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
    export GST_PLUGIN_PATH="$SCRIPT_DIR/video-processing"
    camera=$1

    echo "Starting Camera$camera..."

    test_src_element="videotestsrc ! video/x-raw,width=1920,height=1080,framerate=30/1,format=YUY2"
    overlay="textoverlay text="CAM$camera" valignment=top halignment=left ! timeoverlay valignment=top halignment=right"

    if [ "$TARGET" == "ORIN" ]; then
        if [ "$2" = "true" ]; then
            preprocessing="! preprocessing"
        fi

        if [ "$3" = "true" ]; then
            postprocessing="! postprocessing"
        fi

        if [ "$camera" == "1" ]; then
            device_id="0"
        elif [ "$camera" == "2" ]; then
            device_id="2"
        elif [ "$camera" == "3" ]; then
            device_id="4"
        elif [ "$camera" == "4" ]; then
            device_id="6"
        fi

        cam_src_element="v4l2src device=/dev/video$device_id ! video/x-raw,width=1920,height=1080,framerate=30/1,format=UYVY"
        temp_src_element="v4l2src device=/dev/video$device_id ! image/jpeg,width=640,height=480,framerate=30/1 ! jpegdec ! nvvidconv ! video/x-raw,format=UYVY"
        streaming_pipeline="$cam_src_element ! $overlay $preprocessing $postprocessing ! nvvidconv ! nvv4l2h264enc ! h264parse config-interval=-1 ! rtspclientsink location=rtsp://localhost:8554/stream$camera"
    else
        streaming_pipeline="$test_src_element ! $overlay ! autovideoconvert ! openh264enc ! h264parse ! rtspclientsink location=rtsp://localhost:8554/stream$camera"
    fi

    gst-launch-1.0 -v $streaming_pipeline > /dev/null 2>&1 &
    echo $! > /tmp/gst_pipeline_$camera.pid

    sleep 2
    pid=$(cat /tmp/gst_pipeline_$camera.pid)
    if ps -p $pid > /dev/null; then
        echo "Camera$camera success"
    else
        echo "Camera$camera failed, showing test pattern..."
        # streaming_pipeline="$test_src_element ! $overlay ! nvvidconv ! nvv4l2h264enc ! h264parse config-interval=-1 ! rtspclientsink location=rtsp://localhost:8554/stream$camera"
        streaming_pipeline="$test_src_element ! $overlay ! nvvidconv ! nvv4l2h264enc ! h264parse config-interval=-1 ! rtspclientsink location=rtsp://localhost:8554/stream$camera"
        gst-launch-1.0 -v $streaming_pipeline > /dev/null 2>&1 &
        echo $! > /tmp/gst_pipeline_$camera.pid
        sleep 2

        pid=$(cat /tmp/gst_pipeline_$camera.pid)
        if ! ps -p $pid > /dev/null; then
            echo "Test pattern failed..."
            rm /tmp/gst_pipeline_$camera.pid
        fi
    fi
}

# Function to stop the stream
stop_stream() {
    camera=$1
    if [ -f /tmp/gst_pipeline_$camera.pid ]; then
        # Kill the specific GStreamer pipeline process
        kill "$(cat /tmp/gst_pipeline_$camera.pid)" > /dev/null 2>&1
        rm /tmp/gst_pipeline_$camera.pid
        echo "Camera$1 stopped"
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
