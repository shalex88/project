#!/bin/bash

PROJECT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_NAME=$(basename "$PROJECT_DIR")
PACKAGE_DIR="$PROJECT_DIR"/package
# INSTALL_DIR="$HOME"/"$PROJECT_NAME"
INSTALL_DIR=/opt/"$PROJECT_NAME"
DEPLOY_DIR="$PACKAGE_DIR""$INSTALL_DIR"

clear() {
    find "$PACKAGE_DIR" -mindepth 1 ! -regex "^$PACKAGE_DIR/DEBIAN\(/.*\)?" -delete
}

copy() {
    cp -r "$PROJECT_DIR"/app "$DEPLOY_DIR"
    cp -r "$PROJECT_DIR"/ui "$DEPLOY_DIR"
    cp -r "$PROJECT_DIR"/video "$DEPLOY_DIR"
    cp -r "$PROJECT_DIR"/install.sh "$DEPLOY_DIR"
}

mkdir -p "$DEPLOY_DIR"
copy
dpkg-deb --build "$PACKAGE_DIR" "$PROJECT_NAME".deb
clear