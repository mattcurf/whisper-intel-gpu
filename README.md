# whisper-intel-gpu

This repo provides a quick sample showing the use of OpenAI Whisper speech to text AI model with support for Intel ARC GPU.

# Prerequisites
* Ubuntu 24.04 or newer (for Intel ARC GPU kernel driver support)
* Installed Docker tools (for Linux) 
* Intel ARC series GPU (tested with Intel ARC A770 16GB)
 
# Usage

The following will build the Whisper with Intel ARC GPU support and perform a test speech to text using a precorded audio file

Linux:
```bash
$ git clone https://github.com/mattcurf/whisper-intel-gpu
$ cd whisper-intel-gpu
$ ./build.sh
$ ./run.sh
```

# Known issues
* No effort has been made to prune the packages pulled into the oneAPI docker image for Intel GPU
