FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_PKG=ros_base
ENV ROS_DISTRO=foxy
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL /bin/bash
SHELL ["/bin/bash", "-c"] 

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

# 
# add the ROS deb repo to the apt sources list
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
		curl \
		wget \
		gnupg2 \
		lsb-release \
		ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null


# 
# install development packages
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
		build-essential \
		cmake \
		git \
		libbullet-dev \
		libpython3-dev \
		python3-colcon-common-extensions \
		python3-flake8 \
		python3-pip \
		python3-numpy \
		python3-pytest-cov \
		python3-rosdep \
		python3-setuptools \
		python3-vcstool \
		python3-rosinstall-generator \
		libasio-dev \
		libtinyxml2-dev \
		libcunit1-dev \
		libgazebo9-dev \
		gazebo9 \
		gazebo9-common \
		gazebo9-plugin-base \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# install some pip packages needed for testing
RUN python3 -m pip install -U \
		argcomplete \
		flake8-blind-except \
		flake8-builtins \
		flake8-class-newline \
		flake8-comprehensions \
		flake8-deprecated \
		flake8-docstrings \
		flake8-import-order \
		flake8-quotes \
		pytest-repeat \
		pytest-rerunfailures \
		pytest 
# 
# download/build ROS from source
#
RUN mkdir -p ${ROS_ROOT}/src && \
    cd ${ROS_ROOT} && \

    # https://answers.ros.org/question/325245/minimal-ros2-installation/?answer=325249#post-id-325249
    rosinstall_generator --deps --rosdistro ${ROS_DISTRO} ${ROS_PKG} \
		launch_xml \
		launch_yaml \
		launch_testing \
		launch_testing_ament_cmake \
		demo_nodes_cpp \
		demo_nodes_py \
		example_interfaces \
		camera_calibration_parsers \
		camera_info_manager \
		cv_bridge \
		v4l2_camera \
		vision_opencv \
		vision_msgs \
		image_geometry \
		image_pipeline \
		image_transport \
		compressed_image_transport \
		compressed_depth_image_transport \
		> ros2.${ROS_DISTRO}.${ROS_PKG}.rosinstall && \
    cat ros2.${ROS_DISTRO}.${ROS_PKG}.rosinstall && \
    vcs import src < ros2.${ROS_DISTRO}.${ROS_PKG}.rosinstall && \

    # install dependencies using rosdep
    apt-get update && \
    cd ${ROS_ROOT} && \
    rosdep init && \
    rosdep update && \
    rosdep install -y \
        --ignore-src \
        --from-paths src \
	    --rosdistro ${ROS_DISTRO} && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \

    # build it!
    colcon build --merge-install && \
    
    # remove build files
    rm -rf ${ROS_ROOT}/src && \
    rm -rf ${ROS_ROOT}/logs && \
    rm -rf ${ROS_ROOT}/build && \
    rm ${ROS_ROOT}/*.rosinstall


# source ROS
RUN echo 'source ${ROS_ROOT}/install/setup.bash' >> /root/.bashrc

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
    python3-opencv libopencv-dev libeigen3-dev unzip libtool autoconf automake pkg-config && \
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
    cp libusb/.libs/libusb-1.0.so.0.1.0 /lib/aarch64-linux-gnu/ && \
    ldconfig


RUN git clone https://github.com/pupil-labs/libuvc && \
    cd libuvc && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j && \ 
    make install && \
    ldconfig

RUN echo 'SUBSYSTEM=="usb",  ENV{DEVTYPE}=="usb_device", GROUP="plugdev", MODE="0664"' | tee /etc/udev/rules.d/10-libuvc.rules > /dev/null && \
    udevadm trigger

SHELL ["/bin/bash", "-c", "-i"]

# python libs
RUN git clone https://github.com/pupil-labs/pupil.git && \
    mkvirtualenv pupil && \
    pip install opencv-python && \
    cd pupil && \
    python -m pip install --upgrade pip wheel && \
    pip install -r requirements.txt

RUN echo 'export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1' >> /root/.bashrc

WORKDIR /workspace/pupil/pupil_src

ENTRYPOINT ["tmux"]
