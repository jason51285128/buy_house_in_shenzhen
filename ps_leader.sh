#!/bin/bash

PWD="$(cd "$(dirname "$0")"; pwd)"

ps -efl | grep graber_leader.sh | grep -v grep