FROM ros:crystal-ros-core-bionic
# install ros2 packages
RUN apt-get update && apt-get install -y \
    ros-crystal-ros-base=0.6.1-0* git wget python3-colcon-ros vim \
    && rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/crystal/setup.sh && export CMAKE_PREFIX_PATH=$AMENT_PREFIX_PATH:$CMAKE_PREFIX_PATH && \
cd && mkdir ros2_ws/src -p && cd ros2_ws/src && \
git clone https://github.com/Roboy/roboy_communication.git -b crystal && \
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
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

RUN cd ~ && \
    mkdir -p dlib && \
    git clone https://github.com/davisking/dlib.git dlib/ && \
    cd  dlib/ && \
    python3 setup.py install 

RUN pip3 install face_recognition

RUN pip3 install scientio websockets asyncio redis
RUN pip3 install numpy==1.16 

RUN cd ~ && mkdir workspace && cd workspace && git clone https://github.com/Roboy/face_oracle.git
COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

