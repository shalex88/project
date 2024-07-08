#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

install_autorun_service() {
    sudo cp $SCRIPT_DIR/project.service /etc/systemd/system/project.service
    sudo systemctl daemon-reload
    sudo systemctl enable project
}

install_autorun_service
