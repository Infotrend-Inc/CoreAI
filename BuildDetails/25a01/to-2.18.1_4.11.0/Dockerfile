##### Splitting installation into controlled parts:
## - Base container setup (all apt-get + system + ldd extension)
## - Python pip3 preparation + First batch of python tools installs
## - Tensorflow build and install (optional)
## - FFmpeg build and install
## - OpenCV build and install (using FFmpeg)
## - Additional python tools installs
## - PyTorch (+ vison + audio) build and install (using FFmpeg + OpenCV, optional)
## - Final steps: users + /iti setup, ...

# The idea is to have a base Dockerfile that will be tailored to specific builds 
# so that each build has their own final Dockerfile available for inspection

ARG CoreAI_FROM=ubuntu:24.04
FROM ${CoreAI_FROM}

# No CUDA, or no cuDNN bootstrap needed

ARG CoreAI_NUMPROC=32

##### Base

# Install system packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y --fix-missing\
  && apt-get install -y \
    apt-utils \
    locales \
    wget \
    ca-certificates \
  && apt-get clean

# UTF-8
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

# Install system packages
RUN apt-get install -y \
  # Base
    build-essential \
    checkinstall \
    cmake \
    curl \
    g++ \
    gcc \
    git \
    ninja-build \
    perl \
    patchelf \
    pkg-config \
    protobuf-compiler \
    python3-dev \
    rsync \
    time \
    unzip \
    wget \
    zip \
    zlib1g \
    zlib1g-dev \
  # OpenCV
    doxygen \
    file \
    gfortran \
    gnupg \
    gstreamer1.0-plugins-good \
    imagemagick \
    libatk-adaptor \
    libatlas-base-dev \
    libboost-all-dev \
    libcanberra-gtk-module \
    libdc1394-dev \
    libeigen3-dev \
    libfaac-dev \
    libfreetype6-dev \
    libgflags-dev \
    libglew-dev \
    libglu1-mesa \
    libglu1-mesa-dev \
    libgoogle-glog-dev \
    libgphoto2-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-bad1.0-0 \
    libgstreamer-plugins-base1.0-dev \
    libgtk2.0-dev \
    libgtk-3-dev \
    libhdf5-dev \
    libhdf5-serial-dev \
    libjpeg-dev \
    liblapack-dev \
    libmp3lame-dev \
    libopenblas-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libopenjp2-7 \
    libopenjp2-7-dev \
    libopenjp2-tools \
    libopenjpip-server \
    libpng-dev \
    libpostproc-dev \
    libprotobuf-dev \
    libtbbmalloc2 \
    libtbb-dev \
    libtheora-dev \
    libtiff5-dev \
    libv4l-dev \
    libvorbis-dev \
    libwebp-dev \
    libx264-dev \
    libx265-dev \
    libxi-dev \
    libxine2-dev \
    libxmu-dev \
    libxvidcore-dev \
    libzmq3-dev \
    v4l-utils \
    x11-apps \
    x264 \
    yasm \
  # No adds for torch
  # FFMpeg (source install, do not install packages: libavcodec-dev libavformat-dev libavresample-dev libavutil-dev libswscale-dev)
    libass-dev \
    libc6 \
    libc6-dev \
    libnuma1 \
    libnuma-dev \
    libopus-dev \
    libtool \
    libvpx-dev \
  # CoreAI "user" preparation
    sudo \
    python3-venv \
  && apt-get clean

# No Additional CUDA apt installs


# Not installing clang


ENV CoreAI_BUILD=CPU
RUN touch /tmp/.${CoreAI_BUILD}_build

# - Avoid "RPC failed; curl 56 GnuTLS" issue on some pulls, while keeping the system installed git
# - Some tools expect a "python" binary
# - Prepare ldconfig
RUN git config --global http.postBuffer 1048576000 \
  && mkdir -p /usr/local/bin && ln -s $(which python3) /usr/local/bin/python \
  && mkdir -p /usr/local/lib && sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/usrlocallib.conf' && ldconfig

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Not a GPU build, no path fix to test


# Setup pip
ENV PIP_ROOT_USER_ACTION=ignore
RUN mv /usr/lib/python3.12/EXTERNALLY-MANAGED /usr/lib/python3.12/EXTERNALLY-MANAGED.old \
  && wget -q -O /tmp/get-pip.py --no-check-certificate https://bootstrap.pypa.io/get-pip.py \
  && python3 /tmp/get-pip.py \
  && pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install -U pip \
  && rm -rf /tmp/get-pip.py /root/.cache/pip

# No TensorRT support

# Install Python tools (for buiding) 
RUN pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install -U --ignore-installed \
  # Base
    "cmake>=3.20,<4.0" \
    future \
    mkl \
    mkl-include \
    mock \
    numpy \
    opt_einsum \
    packaging \
    pyyaml \
    requests \
    setuptools \
    six \
    wheel \
  # OpenCV
    lxml \
    Pillow \
  # No Torch addons
  # Extra
    scikit-image \
    scikit-learn \
    matplotlib \
    moviepy \
    pandas \
    mkl-static mkl-include \
  && pip3 install -U keras_preprocessing --no-deps \
  && rm -rf /root/.cache/pip

##### TensorFlow
# https://www.tensorflow.org/install/pip#cpu

ENV CoreAI_TENSORFLOW_VERSION=2.18.1
RUN pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install tensorflow==${CoreAI_TENSORFLOW_VERSION} \
    && rm -rf /root/.cache/pip

# Verify the installation:
RUN python3 -c 'import tensorflow as tf; print(f"{tf.__version__}")' > /tmp/.tensorflow_pip

RUN echo "--- Tensorflow -- PIP Installed: ${CoreAI_TENSORFLOW_VERSION}" > /tmp/tf_env.dump

##### FFMPEG

ENV CoreAI_FFMPEG_VERSION=7.1.1
ENV CoreAI_FFMPEG_NONFREE=""
RUN mkdir -p /usr/local/src/builder \
  && cd /usr/local/src \
  && wget -q https://ffmpeg.org/releases/ffmpeg-${CoreAI_FFMPEG_VERSION}.tar.gz -O - | tar --strip-components=1 -xz -C /usr/local/src/builder \
  && cd /usr/local/src/builder \
  && time ./configure --enable-shared --disable-static --enable-gpl --enable-libv4l2 --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libxvid --enable-libopus --enable-pic --enable-libass --enable-libx264 --enable-libx265 | tee /tmp/ffmpeg_config.txt \
  && make -j${CoreAI_NUMPROC} install \
  && ldconfig \
  && rm -rf /usr/local/src/builder

RUN echo "${CoreAI_FFMPEG_VERSION}" > /tmp/.ffmpeg_built

#### OpenCV

# Download & Build OpenCV in same RUN
## FYI: We are removing the OpenCV source and build directory in /usr/local/src to attempt to save additional disk space
# Comment the last line if you want to rerun cmake with additional/modified options. For example:
# cd /usr/local/src/opencv/build
# cmake -DOPENCV_ENABLE_NONFREE=ON -DBUILD_EXAMPLES=ON -DBUILD_DOCS=ON -DBUILD_TESTS=ON -DBUILD_PERF_TESTS=ON .. && make install
ENV CoreAI_OPENCV_VERSION=4.11.0
ENV CoreAI_OPENCV_CUDA=""
ENV CoreAI_OPENCV_NONFREE=""
RUN mkdir -p /usr/local/src/opencv/build /usr/local/src/opencv_contrib \
  && cd /usr/local/src \
  && wget -q https://github.com/opencv/opencv/archive/${CoreAI_OPENCV_VERSION}.tar.gz -O - | tar --strip-components=1 -xz -C /usr/local/src/opencv \
  && wget -q https://github.com/opencv/opencv_contrib/archive/${CoreAI_OPENCV_VERSION}.tar.gz -O - | tar --strip-components=1 -xz -C /usr/local/src/opencv_contrib \
  && cd /usr/local/src/opencv/build \
  && time cmake \
    -DBUILD_DOCS=0 \
    -DBUILD_EXAMPLES=0 \
    -DBUILD_PERF_TESTS=0 \
    -DBUILD_TESTS=0 \
    -DBUILD_opencv_python2=0 \
    -DBUILD_opencv_python3=1 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
    -DOPENCV_PYTHON3_INSTALL_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
    -DPYTHON_EXECUTABLE=$(which python3) \
    -DCMAKE_INSTALL_TYPE=Release \
    -DENABLE_FAST_MATH=1 \
    -DFORCE_VTK=1 \
    -DINSTALL_C_EXAMPLES=0 \
    -DINSTALL_PYTHON_EXAMPLES=0 \
    -DOPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
    -DOPENCV_GENERATE_PKGCONFIG=1 \
    -DOPENCV_PC_FILE_NAME=opencv.pc \
    -DWITH_CSTRIPES=1 \
    -DWITH_EIGEN=1 \
    -DWITH_GDAL=1 \
    -DWITH_GSTREAMER=1 \
    -DWITH_GSTREAMER_0_10=OFF \
    -DWITH_GTK=1 \
    -DWITH_IPP=1 \
    -DWITH_OPENCL=1 \
    -DWITH_OPENMP=1 \
    -DWITH_TBB=1 \
    -DWITH_V4L=1 \
    -DWITH_WEBP=1 \
    -DWITH_XINE=1 \
    ${CoreAI_OPENCV_CUDA} \
    ${CoreAI_OPENCV_NONFREE} \
    -GNinja \
    .. \
  && time ninja install \
  && ldconfig \
  && rm -rf /usr/local/src/opencv /usr/local/src/opencv_contrib

RUN python3 -c 'import cv2; print(f"{cv2.__version__}")' > /tmp/.opencv_built

# No PyTorch, Torch Audio or Torch Video
RUN echo "No PyTorch built" > /tmp/torch_config.txt \
  && echo "No TorchVision built" > /tmp/torchvision_config.txt \
  && echo "No TorchAudio built" > /tmp/torchaudio_config.txt \
  && echo "No TorchData built" > /tmp/torchdata_config.txt \
  && echo "No TorchText built" > /tmp/torchtext_config.txt


##### Final steps

##### Jupyter lab & venv requirements
RUN pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install -U jupyterlab ipywidgets \
  && jupyter labextension enable widgetsnbextension \
  && rm -rf /root/.cache/pip
# https://jupyterlab.readthedocs.io/en/stable/getting_started/changelog.html
# with v4 extensions are installed using the extension manager, see https://jupyterlab.readthedocs.io/en/stable/user/extensions.html#id11

RUN touch /.within_container
COPY withincontainer_checker.sh /tmp/withincontainer_checker.sh
RUN chmod +x /tmp/withincontainer_checker.sh \
  && /tmp/withincontainer_checker.sh

# Every sudo group user does not need a password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create a new group for the coreai user
RUN groupadd -g 1024 coreai \
  && groupadd -g 1025 coreaitoo

# The coreai user will have UID 1024, 
# be part of the coreai and users groups and be sudo capable (passwordless) 
RUN useradd -u 1024 -d /home/coreai -g coreai -s /bin/bash -m coreai \
    && usermod -G users coreai \
    && adduser coreai sudo
# The coreaitoo user will have UID 1025, 
RUN useradd -u 1025 -d /home/coreaitoo -g coreaitoo -s /bin/bash -m coreaitoo \
    && usermod -G users coreaitoo \
    && adduser coreaitoo sudo

# Setting up working directory 
RUN mkdir /iti \
    && chown -R coreai:coreai /iti

COPY entrypoint.sh /entrypoint.sh
COPY run_jupyter.sh /run_jupyter.sh
RUN chmod 755 /entrypoint.sh /run_jupyter.sh

EXPOSE 8888

# Switch to coreaitoo user
USER coreaitoo
WORKDIR /iti

ENTRYPOINT ["/entrypoint.sh"]