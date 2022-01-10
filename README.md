# aarch64 docker image including source build of [Pupil Labs Pupil](https://github.com/pupil-labs/pupil.git) and [ROS2](https://github.com/ros2)
Although this repository is dedicated to the installation of Pupil Labs on an arm64 linux platform, it should also be a useful reference on other platforms by rebuilding the Dockerfile with slight modifications.

## Usage
You can directly download and exectute the image from dockerhub via:
``` bash
$ docker run --privileged -it -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY --network host -v /dev:/dev -v /mnt:/mnt -v timongentzsch/aarch64-pupil
```

## Development
To quickly iterate your build process and application please refer to the scripts provided in my other [repo](https://github.com/timongentzsch/Jetson_Ubuntu20_Images/tree/master/scripts).
## Work with the provided scripts

You may want to install the provided scripts to build, run and restart containers with the right set of docker flags:
``` bash
$ sudo scripts/install-scripts.sh
```
After that you can use following commands globally:
`dbuild`, `drun`, `dstart`

It ensures that the docker environment feels as native as possible by enabling the following features by default:
- USB hot plug
- sound
- network
- bluetooth
- GPU/cuda
- X11
>  **note:** refer to `--help` for the syntax

