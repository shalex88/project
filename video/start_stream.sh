#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

debug_print() {
    if [ -n "$DEBUG" ]; then
        echo "$1"
    fi
}

usage() {
    echo "usage: $(basename "$0") [CAMERA_ID] [RUN] [PREPROCESSING] [POSTPROCESSING]"
    echo "CAMERA_ID <1|2|..|all> - template project language"
    echo "RUN <start|stop> - template project language"
    echo "PREPROCESSING <true|false> - custom preprocessing element"
    echo "POSTPROCESSING <true|false> - custom postprocessing element"
    echo "example:"
    echo "./$(basename "$0") all start true true"
    echo "./$(basename "$0") all stop"
}

# Function to start the stream
start_stream() {
    [[ -s /home/fronti/.hailo/tappas/tappas_env ]] && . /home/fronti/.hailo/tappas/tappas_env
    export GST_PLUGIN_PATH+="$SCRIPT_DIR/video-processing"
    camera=$1

    stop_stream $camera
    echo "Starting Camera$camera..."

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

    # Stream settings
    in_format="video/x-raw,format=UYVY"

    fps="framerate=30/1"
    hd_in_resolution=",width=1920,height=1080,$fps"
    no_in_resolution=""
    in_resolution=$hd_in_resolution

    # Sources
    cam_src_element="v4l2src device=/dev/video$device_id ! $in_format $in_resolution "
    test_src_element="videotestsrc ! $in_format $in_resolution "
    hailo_src_element="videotestsrc pattern="ball" ! $in_format $in_resolution "
    movie_file="pedestrians.mp4"
    movie_src_element="filesrc location=$SCRIPT_DIR/tests/movies/$movie_file ! decodebin ! autovideoconvert"

    # Video processing
    cam_overlay="! textoverlay text="CAM$camera" valignment=top halignment=left ! timeoverlay valignment=top halignment=right"
    no_overlay=""

    # Video processing
    hailo_stabilization="! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! videoscale qos=false n-threads=2 ! video/x-raw, pixel-aspect-ratio=1/1 ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! videoconvert n-threads=2 qos=false ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! hailonet hef-path=/media/fronti/NVMe/hailo_4.15.0/tappas/apps/h8/gstreamer/resources/hef/yolov5m_wo_spp_60p.hef batch-size=1 nms-score-threshold=0.3 nms-iou-threshold=0.45 output-format-type=HAILO_FORMAT_TYPE_FLOAT32 ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! hailofilter function-name=yolov5 so-path=/media/fronti/NVMe/hailo_4.15.0/tappas/apps/h8/gstreamer/libs/post_processes//libyolo_hailortpp_post.so config-path=null qos=false ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! hailooverlay qos=false ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! videoconvert "
    multiple_video_processing="$preprocessing $postprocessing"
    no_video_processing=""

    # Encoders
    ecoder_format="video/x-raw(memory:NVMM),format=NV12"
    max_out_resolution=",width=3840,height=2160,$fps"
    no_out_resolution=""
    out_resolution="$max_out_resolution"

    nvh264_enc="nvvidconv ! $ecoder_format $out_resolution ! nvv4l2h264enc ! h264parse"
    swh264_enc="autovideoconvert ! x264enc ! h264parse"
    nvh265_enc="nvvidconv ! $ecoder_format $out_resolution ! nvv4l2h265enc ! h265parse"
    swh265_enc="autovideoconvert ! x265enc ! h264parse"

    # Sinks
    rtspclientsink="rtspclientsink location=rtsp://localhost:8554/stream$camera"

    # Final pipeline
    source=$cam_src_element
    overlay=$cam_overlay
    video_processing=$multiple_video_processing
    if [ "$TARGET" == "ORIN" ]; then
        encoder=$nvh264_enc
    else
        encoder=$swh264_enc
    fi
    sink=$rtspclientsink

    streaming_pipeline="$source $overlay $video_processing ! $encoder ! $sink"

    debug_print "gst-launch-1.0 -v $streaming_pipeline"

    # Play
    gst-launch-1.0 $streaming_pipeline > /dev/null 2>&1 &
    echo $! > /tmp/gst_pipeline_$camera.pid

    # Check if the pipeline is running
    sleep 2
    pid=$(cat /tmp/gst_pipeline_$camera.pid)
    if ps -p $pid > /dev/null; then
        echo "Camera$camera success"
    else
        echo "Camera$camera failed, showing test pattern..."
        source=$test_src_element
        streaming_pipeline="$source $overlay ! $encoder ! $sink"
        debug_print "gst-launch-1.0 -v $streaming_pipeline"
        gst-launch-1.0 $streaming_pipeline > /dev/null 2>&1 &
        echo $! > /tmp/gst_pipeline_$camera.pid
        sleep 2

        pid=$(cat /tmp/gst_pipeline_$camera.pid)
        if ! ps -p $pid > /dev/null; then
            echo "Test pattern failed..."
            rm /tmp/gst_pipeline_$camera.pid
        fi
    fi
}

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
                usage
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
                usage
                exit 1
                ;;
        esac
        ;;
    *)
        usage
        exit 1
        ;;
esac
