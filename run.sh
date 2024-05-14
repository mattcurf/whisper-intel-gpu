#!/bin/bash
docker run -it --rm  --device /dev/dri:/dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY whisper-intel-gpu 

