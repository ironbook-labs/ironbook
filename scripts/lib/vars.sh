#!/usr/bin/env bash

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
SCRIPTS_DIR="$ROOT_DIR/scripts"
COMPOSER_DIR="$ROOT_DIR/infra/docker/compose"
APPS_DIR="$ROOT_DIR/apps"
API_DIR="$APPS_DIR/api"
HOME_DIR="$APPS_DIR/home"
DESKTOP_DIR="$APPS_DIR/desktop"
ANDROID_DIR="$APPS_DIR/android"
WEB_DIR="$APPS_DIR/web"
OUTPUT_DIR="$ROOT_DIR/output"
API_LINUX_OUTPUT="$OUTPUT_DIR/api/linux"
API_WINDOWS_OUTPUT="$OUTPUT_DIR/api/windows"
HOME_OUTPUT="$OUTPUT_DIR/home"
DESKTOP_LINUX_OUTPUT="$OUTPUT_DIR/desktop/linux"
DESKTOP_WINDOWS_OUTPUT="$OUTPUT_DIR/desktop/windows"
ANDROID_OUTPUT="$OUTPUT_DIR/android"
WINDOWS_INSTALLER_OUTPUT="$OUTPUT_DIR/installer/"
