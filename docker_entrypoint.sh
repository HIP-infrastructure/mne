#!/bin/bash
export HOME=/home/$(whoami)
export SHELL=$(which bash)

$APP_CMD
