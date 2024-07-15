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
    [[ -s /home/fronti/.hailo/tappas/tappas_env ]] && . /home/fronti/.hailo/tappas/tappas_env
    export GST_PLUGIN_PATH+="$SCRIPT_DIR/video-processing"
    camera=$1

    echo "Starting Camera$camera..."

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

        fps="framerate=30/1"
        input_src_resolution="width=1920,height=1080,$fps"
        encoder_input_resolution="width=3840,height=2160,$fps"
        cam_src_element="v4l2src device=/dev/video$device_id ! video/x-raw,$input_src_resolution,format=UYVY"
        overlay="textoverlay text="CAM$camera" valignment=top halignment=left ! timeoverlay valignment=top halignment=right $preprocessing $postprocessing"
        test_src_element="videotestsrc ! video/x-raw,$input_src_resolution,format=UYVY"
        #################### Hailo #########################
        hailo="queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! videoscale qos=false n-threads=2 ! video/x-raw, pixel-aspect-ratio=1/1 ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! videoconvert n-threads=2 qos=false ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! hailonet hef-path=/media/fronti/NVMe/hailo_4.15.0/tappas/apps/h8/gstreamer/resources/hef/yolov5m_wo_spp_60p.hef batch-size=1 nms-score-threshold=0.3 nms-iou-threshold=0.45 output-format-type=HAILO_FORMAT_TYPE_FLOAT32 ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! hailofilter function-name=yolov5 so-path=/media/fronti/NVMe/hailo_4.15.0/tappas/apps/h8/gstreamer/libs/post_processes//libyolo_hailortpp_post.so config-path=null qos=false ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! hailooverlay qos=false ! queue leaky=no max-size-buffers=30 max-size-bytes=0 max-size-time=0 ! videoconvert "
        # test_src_element="videotestsrc pattern="ball" ! video/x-raw,$input_src_resolution,format=UYVY"
        # overlay="textoverlay text="CAM$camera" valignment=top halignment=left ! timeoverlay valignment=top halignment=right ! $hailo"
        ####################################################
        nvh264encoding="nvvidconv ! video/x-raw(memory:NVMM),$encoder_input_resolution,format=NV12 ! nvv4l2h264enc ! h264parse config-interval=-1"
        swh264encoding="autovideoconvert ! openh264enc ! h264parse config-interval=-1"
        nvh265encoding="nvvidconv ! video/x-raw(memory:NVMM),$encoder_input_resolution,format=NV12 ! nvv4l2h265enc ! h265parse config-interval=-1"
        swh265encoding="autovideoconvert ! x265enc ! h264parse config-interval=-1"
        streaming_pipeline="$cam_src_element ! $overlay ! $nvh264encoding ! rtspclientsink location=rtsp://localhost:8554/stream$camera"
    else
        streaming_pipeline="$test_src_element ! $swh264encoding ! rtspclientsink location=rtsp://localhost:8554/stream$camera"
    fi

    gst-launch-1.0 -v $streaming_pipeline > /dev/null 2>&1 &
    echo $! > /tmp/gst_pipeline_$camera.pid

    sleep 2
    pid=$(cat /tmp/gst_pipeline_$camera.pid)
    if ps -p $pid > /dev/null; then
        echo "Camera$camera success"
    else
        echo "Camera$camera failed, showing test pattern..."
        streaming_pipeline="$test_src_element ! $overlay ! $nvh264encoding ! rtspclientsink location=rtsp://localhost:8554/stream$camera"
        gst-launch-1.0 -v $streaming_pipeline > /dev/null &
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
