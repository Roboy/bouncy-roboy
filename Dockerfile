FROM ros:dashing-ros-base-bionic
# install ros2 packages
RUN apt-get update && apt-get install -y \
    git wget python3-colcon-ros vim \
    && rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/dashing/setup.sh && export CMAKE_PREFIX_PATH=$AMENT_PREFIX_PATH:$CMAKE_PREFIX_PATH && \
cd && mkdir ros2_ws/src -p && cd ros2_ws/src && \
git clone https://github.com/Roboy/roboy_communication.git -b ros1bridge && \
git clone https://github.com/Roboy/pyroboy.git && \
cd .. && colcon build --symlink-install

RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository universe && add-apt-repository main

RUN apt-get update && apt-get install -y --fix-missing \
    build-essential \
    cmake \
    gfortran \
    git \
    wget \
    curl \
    graphicsmagick \
    libgraphicsmagick1-dev \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    liblapack-dev \
    libswscale-dev \
    pkg-config \
    python3-dev \
    python3-numpy \
    software-properties-common \
    zip \
    alsa-utils \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*


# ros melodic
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# install ros packages
ENV ROS_DISTRO melodic
RUN apt-get update && apt-get install -y \
    ros-melodic-ros-base=1.4.1-0* \
    && rm -rf /var/lib/apt/lists/*

# fix weird cmake issue
RUN apt-get update && apt-get install -y python-pip ros-dashing-launch-testing ros-dashing-launch-testing-ros ros-dashing-launch-testing-ament-cmake ros-dashing-ros2run && \
    pip install cmake

# roboy_communication for melodic
RUN cd ~ && mkdir -p ~/melodic_ws/src && \
    cd ~/melodic_ws/src && git clone https://github.com/Roboy/roboy_communication.git && \
    cd ~/melodic_ws && . /opt/ros/melodic/setup.sh && catkin_make

# ros1_bridge
RUN mkdir -p ~/ros1_bridge_ws/src && cd ~/ros1_bridge_ws/src && \
    git clone https://github.com/ros2/ros1_bridge.git -b dashing

RUN . ~/melodic_ws/devel/setup.sh && \
    . /opt/ros/dashing/setup.sh && . ~/ros2_ws/install/setup.sh && \
    export CMAKE_PREFIX_PATH=$AMENT_PREFIX_PATH:$CMAKE_PREFIX_PATH && \
    cd ~/ros1_bridge_ws && colcon build --symlink-install

# dlib
RUN cd ~ && \
    mkdir -p dlib && \
    git clone https://github.com/davisking/dlib.git dlib/ && \
    cd  dlib/ && \
    python3 setup.py install

RUN pip3 install face_recognition

RUN pip3 install scientio websockets asyncio redis
RUN pip3 install numpy==1.16

RUN cd ~ && mkdir workspace && cd workspace && git clone https://github.com/Roboy/face_oracle.git
# COPY ./entrypoint.sh /
# ENTRYPOINT ["/entrypoint.sh"]
