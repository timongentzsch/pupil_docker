# Docker image including source build of [Pupil Labs Pupil](https://github.com/pupil-labs/pupil.git) and [ROS2 (foxy)](https://github.com/ros2)
## Info
This image includes all neccessary libraries to run Pupil Labs Pupil from source. For compatibility reasons all python packages are build against a venv of `python3.6`.

## Usage
You can directly download and exectute the image from dockerhub via:
``` bash
xhost +
docker run --privileged -it -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY --network host -v /dev:/dev timongentzsch/x86-pupil
```
to start pupil labs:
``` bash
workon pupil
python main.py capture
```
## Development
To quickly iterate your build process and application please refer to the scripts provided in my other [repo](https://github.com/timongentzsch/Jetson_Ubuntu20_Images/tree/master/scripts).
### Work with the provided scripts

You may want to install the provided scripts to build, run and restart containers with the right set of docker flags:
``` bash
sudo scripts/install-scripts.sh
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

