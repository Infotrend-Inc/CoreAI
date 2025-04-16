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

ARG CoreAI_FROM=nvidia/cuda:12.6.3-devel-ubuntu24.04
FROM ${CoreAI_FROM}

# Extended from https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/12.6.3/ubuntu2404/devel/cudnn/Dockerfile
ENV NV_CUDNN_VERSION=9.5.1.17-1
ENV NV_CUDNN_PACKAGE_NAME="libcudnn9-cuda-12"
ENV NV_CUDNN_PACKAGE="libcudnn9-cuda-12=${NV_CUDNN_VERSION}"
ENV NV_CUDNN_PACKAGE_DEV="libcudnn9-dev-cuda-12=${NV_CUDNN_VERSION}"

LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    ${NV_CUDNN_PACKAGE_DEV} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME}

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
  # Torch
    libomp-dev \
    libsox-dev \
    libsox-fmt-all \
    libsphinxbase-dev \
    sphinxbase-utils \
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

# Additional CUDA apt installs (with --no-install-recommends)
ENV CoreAI_CUDA_APT=
RUN apt-get install -y --no-install-recommends \
    time ${CoreAI_CUDA_APT} \
  && apt-get clean

# Add libEGL & Vuulkan ICD loaders and libraries
RUN apt install -y libglvnd0 libglvnd-dev libegl1-mesa-dev libvulkan1 libvulkan-dev \
    && apt-get clean \
    && mkdir -p /usr/share/glvnd/egl_vendor.d \
    && echo '{"file_format_version":"1.0.0","ICD":{"library_path":"libEGL_nvidia.so.0"}}' > /usr/share/glvnd/egl_vendor.d/10_nvidia.json \
    && mkdir -p /usr/share/vulkan/icd.d \
    && echo '{"file_format_version":"1.0.0","ICD":{"library_path":"libGLX_nvidia.so.0","api_version":"1.3"}}' > /usr/share/vulkan/icd.d/nvidia_icd.json
ENV MESA_D3D12_DEFAULT_ADAPTER_NAME="NVIDIA"

ENV NVIDIA_DRIVER_CAPABILITIES="all"
ENV NVIDIA_VISIBLE_DEVICES="all"


ENV CoreAI_CLANG_VERSION=17
RUN apt-get install -y lsb-release software-properties-common gnupg \
  && mkdir /tmp/clang \
  && cd /tmp/clang \
  && wget https://apt.llvm.org/llvm.sh \
  && chmod +x llvm.sh \
  && ./llvm.sh ${CoreAI_CLANG_VERSION} \
  && cd / \
  && rm -rf /tmp/clang
RUN which clang-${CoreAI_CLANG_VERSION} \
  && which clang++-${CoreAI_CLANG_VERSION} \
  && clang-${CoreAI_CLANG_VERSION} --version \
  && clang++-${CoreAI_CLANG_VERSION} --version

ENV CoreAI_BUILD=GPU
RUN touch /tmp/.${CoreAI_BUILD}_build

# - Avoid "RPC failed; curl 56 GnuTLS" issue on some pulls, while keeping the system installed git
# - Some tools expect a "python" binary
# - Prepare ldconfig
RUN git config --global http.postBuffer 1048576000 \
  && mkdir -p /usr/local/bin && ln -s $(which python3) /usr/local/bin/python \
  && mkdir -p /usr/local/lib && sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/usrlocallib.conf' && ldconfig

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Misc GPU fixes
RUN cd /usr/local \
  && if [ -e cuda ]; then if [ ! -e nvidia ]; then ln -s cuda nvidia; fi; fi \
  && tmp="/usr/local/cuda/extras/CUPTI/lib64" \
  && if [ -d $tmp ]; then \ 
        echo $tmp >> /etc/ld.so.conf.d/nvidia-cupti.conf; \
        ldconfig; \
        echo "***** CUPTI added to LD path"; \
     fi


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
  # Torch
    cffi \
    typing \
    ninja \
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
# https://www.tensorflow.org/install/source

## Download & Building TensorFlow from source in same RUN
ENV LATEST_BAZELISK=1.25.0
ENV CoreAI_TENSORFLOW_VERSION=2.19.0
ENV CoreAI_TF_CONFIG="--config=cuda"
ENV TF_CUDA_COMPUTE_CAPABILITIES=6.0,6.1,7.0,7.5,8.0,8.6,8.9,9.0

# See https://github.com/tensorflow/tensorflow/blob/master/configure.py for new TF_NEED_
ENV TF_NEED_CUDA=1
ENV TF_CUDA_CLANG=1
ENV TF_NEED_TENSORRT=0 
ENV TF_NEED_AWS=0 
ENV TF_NEED_CLANG=1
ENV TF_NEED_COMPUTECPP=0 
ENV TF_NEED_GCP=0 
ENV TF_NEED_GDR=0
ENV TF_NEED_HDFS=0 
ENV TF_NEED_JEMALLOC=0
ENV TF_NEED_KAFKA=0
ENV TF_NEED_MKL=1
ENV TF_NEED_MPI=0
ENV TF_NEED_OPENCL=0
ENV TF_NEED_OPENCL_SYCL=0
ENV TF_NEED_ROCM=0
ENV TF_NEED_S3=0
ENV TF_NEED_VERBS=0
ENV TF_SET_ANDROID_WORKSPACE=0
ENV HERMETIC_CUDA_COMPUTE_CAPABILITIES=$TF_CUDA_COMPUTE_CAPABILITIES

RUN curl -s -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v${LATEST_BAZELISK}/bazelisk-linux-amd64 \
  && chmod +x /usr/local/bin/bazel \
  && mkdir -p /usr/local/src/tensorflow \
  && cd /usr/local/src \
  && wget -q -c https://github.com/tensorflow/tensorflow/archive/v${CoreAI_TENSORFLOW_VERSION}.tar.gz -O - | tar --strip-components=1 -xz -C /usr/local/src/tensorflow \
  && cd /usr/local/src/tensorflow \
  && bazel version \
  && ./configure \
  && time bazel build --verbose_failures --config=opt --config=v2 ${CoreAI_TF_CONFIG} //tensorflow/tools/pip_package:wheel --repo_env=WHEEL_NAME=tensorflow --config=cuda --config=cuda_wheel \
  && time pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install bazel-bin/tensorflow/tools/pip_package/wheel_house/tensorflow-*.whl \
  && rm -rf /usr/local/src/tensorflow /tmp/tensorflow_pkg /tmp/bazel_check.pl /tmp/tf_build.sh /tmp/hsperfdata_root /root/.cache/bazel /root/.cache/pip /root/.cache/bazelisk

RUN python3 -c 'import tensorflow as tf; print(f"{tf.__version__}")' > /tmp/.tensorflow_built

RUN echo "--- Tensorflow Build: Environment variables set --- " > /tmp/tf_env.dump \
  && env | grep TF_ | grep -v CoreAI_ | sort >> /tmp/tf_env.dump

##### FFMPEG

ENV CoreAI_FFMPEG_VERSION=7.1.1
ENV CoreAI_FFMPEG_NVCODEC=12.2.72.0 
ENV CoreAI_FFMPEG_NONFREE=""
RUN mkdir -p /usr/local/src/builder \
  && cd /usr/local/src \
  && wget -q https://github.com/FFmpeg/nv-codec-headers/archive/refs/tags/n${CoreAI_FFMPEG_NVCODEC}.tar.gz -O - | tar --strip-components=1 -xz -C /usr/local/src/builder \
  && cd /usr/local/src/builder \
  && make install \
  && rm -rf /usr/local/src/builder
RUN mkdir -p /usr/local/src/builder \
  && cd /usr/local/src \
  && wget -q https://ffmpeg.org/releases/ffmpeg-${CoreAI_FFMPEG_VERSION}.tar.gz -O - | tar --strip-components=1 -xz -C /usr/local/src/builder \
  && cd /usr/local/src/builder \
  && time ./configure --enable-cuda --enable-cuvid --enable-nvdec --enable-nvenc ${CoreAI_FFMPEG_NONFREE} --extra-cflags="-I/usr/local/cuda/include/ -fPIC" --extra-ldflags="-L/usr/local/cuda/lib64/ -Wl,-Bsymbolic" --enable-shared --disable-static --enable-gpl --enable-libv4l2 --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libxvid --enable-libopus --enable-pic --enable-libass --enable-libx264 --enable-libx265 | tee /tmp/ffmpeg_config.txt \
  && make -j${CoreAI_NUMPROC} install \
  && ldconfig \
  && rm -rf /usr/local/src/builder
# From https://docs.nvidia.com/video-technologies/video-codec-sdk/ffmpeg-with-nvidia-gpu/#basic-testing
# GPU Testing: ffmpeg -y -vsync 0 -hwaccel cuda -hwaccel_output_format cuda -i input.mp4 -c:a copy -c:v h264_nvenc -b:v 5M output.mp4
# GPU Testing: ffmpeg -y -vsync 0 -hwaccel cuvid -c:v h264_cuvid -i in.mp4 -c:v hevc_nvenc out.mkv

RUN echo "${CoreAI_FFMPEG_VERSION}" > /tmp/.ffmpeg_built

#### OpenCV

# Download & Build OpenCV in same RUN
## FYI: We are removing the OpenCV source and build directory in /usr/local/src to attempt to save additional disk space
# Comment the last line if you want to rerun cmake with additional/modified options. For example:
# cd /usr/local/src/opencv/build
# cmake -DOPENCV_ENABLE_NONFREE=ON -DBUILD_EXAMPLES=ON -DBUILD_DOCS=ON -DBUILD_TESTS=ON -DBUILD_PERF_TESTS=ON .. && make install
ENV CoreAI_OPENCV_VERSION=4.11.0
ENV CoreAI_OPENCV_CUDA="-DWITH_CUDA=1 -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs -DCUDA_FAST_MATH=1 -DWITH_CUBLAS=1 -DWITH_NVCUVENC=0 -DWITH_NVCUVID=0 -DCUDA_ARCH_BIN=6.0,6.1,7.0,7.5,8.0,8.6,8.9,9.0 -DCUDA_ARCH_PTX=6.0,6.1,7.0,7.5,8.0,8.6,8.9,9.0"
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

##### Torch (using FFMpeg + OpenCV + Magma [GPU only])

ENV CoreAI_TORCH_CUDA_ARCH="6.0 6.1 7.0 7.5 8.0 8.6 8.9 9.0+PTX"

ENV CoreAI_TORCH=2.6.0
# For details on the TORCH_CUDA_ARCH_LIST, see https://pytorch.org/docs/stable/cpp_extension.html
RUN mkdir -p /usr/local/src \
  && cd /usr/local/src \
  && git clone --depth 1 --recurse-submodule --branch v${CoreAI_TORCH} https://github.com/pytorch/pytorch.git  \
  && cd /usr/local/src/pytorch \
  && pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install -r requirements.txt \
  && time env PYTORCH_BUILD_VERSION=${CoreAI_TORCH} PYTORCH_BUILD_NUMBER=0 USE_CUDA=1 USE_CUDNN=1 CAFFE2_USE_CUDNN=1 TORCH_CUDA_ARCH_LIST="${CoreAI_TORCH_CUDA_ARCH}" USE_MKLDNN=1 USE_FFMPEG=1 USE_OPENCV=1 python3 ./setup.py bdist_wheel | tee /tmp/torch_config.txt \
  && time pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install /usr/local/src/pytorch/dist/*.whl \
  && cd /tmp \
  && perl -i.bak -pe 'exit if m%^-- Configuring done%' torch_config.txt \
  && sh -c "cmp --silent torch_config.txt torch_config.txt.bak && exit 1 || rm torch_config.txt.bak" \
  && ldconfig \
  && rm -rf /root/.cache/pip /usr/local/src/pytorch

RUN python3 -c 'import torch; print(f"{torch.__version__}")' > /tmp/.torch_built

# Note: NOT building with Video Codec SDK as it requires an Nvidia account
ENV CoreAI_TORCHVISION=0.21.0
# setup.py options from https://github.com/pytorch/vision/blob/main/setup.py
RUN mkdir -p /usr/local/src \
  && cd /usr/local/src \
  && git clone --depth 1 --recurse-submodule --branch v${CoreAI_TORCHVISION} https://github.com/pytorch/vision.git  \
  && cd /usr/local/src/vision \
  && time env BUILD_VERSION=${CoreAI_TORCHVISION} FORCE_CUDA=1 TORCH_CUDA_ARCH_LIST="${CoreAI_TORCH_CUDA_ARCH}" TORCHVISION_USE_FFMPEG=1 python3 ./setup.py bdist_wheel | tee /tmp/torchvision_config.txt \
  && time pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install /usr/local/src/vision/dist/*.whl \
  && cd /tmp \
  && perl -i.bak -pe 'exit if m%^running bdist_wheel%' torchvision_config.txt \
  && sh -c "cmp --silent torchvision_config.txt torchvision_config.txt.bak && exit 1 || rm torchvision_config.txt.bak" \
  && ldconfig \
  && rm -rf /root/.cache/pip /usr/local/src/vision

RUN python3 -c 'import torchvision; print(f"{torchvision.__version__}")' > /tmp/.torchvision_built

ENV CoreAI_TORCHAUDIO=2.6.0
# setup.py options from https://github.com/pytorch/audio/blob/main/tools/setup_helpers/extension.py
RUN mkdir -p /usr/local/src \
  && cd /usr/local/src \
  && git clone --depth 1 --recurse-submodule --branch v${CoreAI_TORCHAUDIO} https://github.com/pytorch/audio.git \
  && cd /usr/local/src/audio \
  && time env BUILD_VERSION=${CoreAI_TORCHAUDIO} USE_CUDA=1 TORCH_CUDA_ARCH_LIST="${CoreAI_TORCH_CUDA_ARCH}" USE_FFMPEG=1 python3 ./setup.py bdist_wheel | tee /tmp/torchaudio_config.txt \
  && time pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install /usr/local/src/audio/dist/*.whl \
  && cd /tmp \
  && perl -i.bak -pe 'exit if m%^-- Configuring done%' torchaudio_config.txt \
  && sh -c "cmp --silent torchaudio_config.txt torchaudio_config.txt.bak && exit 1 || rm torchaudio_config.txt.bak" \
  && ldconfig \
  && rm -rf /root/.cache/pip /usr/local/src/audio
  
RUN python3 -c 'import torchaudio; print(f"{torchaudio.__version__}")' > /tmp/.torchaudio_built

ENV CoreAI_TORCHDATA=0.11.0
RUN mkdir -p /usr/local/src \
  && cd /usr/local/src \
  && git clone --depth 1 --recurse-submodule --branch v${CoreAI_TORCHDATA} https://github.com/pytorch/data.git  \
  && cd /usr/local/src/data \
  && BUILD_VERSION=${CoreAI_TORCHDATA} pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install . | tee /tmp/torchdata_config.txt \
  && rm -rf /root/.cache/pip /usr/local/src/data

RUN python3 -c 'import torchdata; print(f"{torchdata.__version__}")' > /tmp/.torchdata_built

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
COPY config.sh /coreai_config.sh
RUN chmod 755 /entrypoint.sh /run_jupyter.sh /coreai_config.sh

EXPOSE 8888

# Switch to coreaitoo user
USER coreaitoo
WORKDIR /iti

ENTRYPOINT ["/entrypoint.sh"]