#!/bin/bash -e

install_dependencies() {
    ./web-server/install.sh
    ./media-server/install.sh
}

install_dependencies
