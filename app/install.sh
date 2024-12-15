#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

install_autorun_service() {
    sudo cp $SCRIPT_DIR/project.service /etc/systemd/system/project.service
    sudo systemctl daemon-reload
}

install_core_app() {
    cd $SCRIPT_DIR/project-core
    cargo build
}

install_autorun_service
install_core_app
