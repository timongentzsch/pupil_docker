FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

#
# change the locale from POSIX to UTF-8
#

RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV PYTHONIOENCODING=utf-8

# 
# ros2
#

# add the ROS deb repo to the apt sources list
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
		curl \
		wget \
		gnupg2 \
		lsb-release \
		ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# install ros2 packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
		ros-foxy-desktop \
		python3-colcon-common-extensions && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# source ROS
RUN echo "source /opt/ros/foxy/setup.bash" >> /root/.bashrc

# tools
RUN apt-get update && \
    apt-get install --no-install-recommends -y vim tmux gedit && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN cd /root && \
    touch .tmux.conf && \
    echo 'set -g mouse on' >> .tmux.conf

# 
# pupil labs
#

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential cmake git python3-dev python3-pip python3-setuptools udev libudev-dev software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN add-apt-repository ppa:deadsnakes/ppa

# install python3 virtualenv
RUN pip3 install virtualenvwrapper

RUN echo '' >> /root/.bashrc && \
    echo '# source virtualenv' >> /root/.bashrc && \
    echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3' >> /root/.bashrc && \ 
    echo 'export WORKON_HOME=/root/.virtualenvs' >> /root/.bashrc && \
    echo 'export PROJECT_HOME=/Devel' >> /root/.bashrc && \
    echo 'source /usr/local/bin/virtualenvwrapper.sh' >> /root/.bashrc

# apt libs
RUN apt-get update && \
    apt-get install -y --no-install-recommends pkg-config git cmake build-essential nasm wget python3-setuptools libusb-1.0-0-dev python3-dev python3-pip python3-numpy python3-scipy libglew-dev libtbb-dev \
    libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev libswscale-dev libavresample-dev ffmpeg x264 x265 libportaudio2 portaudio19-dev \
    python3-opencv libopencv-dev libeigen3-dev unzip libtool && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# source libs
RUN wget -O libjpeg-turbo.tar.gz https://sourceforge.net/projects/libjpeg-turbo/files/1.5.1/libjpeg-turbo-1.5.1.tar.gz/download && \
    tar xvzf libjpeg-turbo.tar.gz && \
    cd libjpeg-turbo-1.5.1 && \
    ./configure --enable-static=no --prefix=/usr/local && \
    make install && \
    ldconfig

RUN wget https://github.com/pupil-labs/libusb/archive/refs/tags/v1.0.21-rc6-fixes.zip && \
    unzip v1.0.21-rc6-fixes.zip && \
    cd libusb-1.0.21-rc6-fixes && \
    ./autogen.sh && \
    make && \
    cp libusb/.libs/libusb-1.0.so* /usr/lib/aarch64-linux-gnu/


RUN git clone https://github.com/pupil-labs/libuvc && \
    cd libuvc && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j && \ 
    make install

RUN echo 'SUBSYSTEM=="usb",  ENV{DEVTYPE}=="usb_device", GROUP="plugdev", MODE="0664"' | tee /etc/udev/rules.d/10-libuvc.rules > /dev/null && \
    udevadm trigger

SHELL ["/bin/bash", "-c", "-i", "-l"]

# python libs
RUN apt-get update && \
    apt-get install -y autoconf python3.6-dev && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN git clone https://github.com/pupil-labs/pupil.git && \
    mkvirtualenv -p python3.6 pupil && \
    pip install opencv-python && \
    cd pupil && \
    python -m pip install --upgrade pip wheel && \
    pip install -r requirements.txt

RUN echo 'export LD_PRELOAD=/lib/aarch64-linux-gnu/libgomp.so.1' >> /root/.bashrc

WORKDIR /workspace/pupil

ENTRYPOINT ["tmux"]
