#### OpenCV

# Download & Build OpenCV in same RUN
## FYI: We are removing the OpenCV source and build directory in /usr/local/src to attempt to save additional disk space
# Comment the last line if you want to rerun cmake with additional/modified options. For example:
# cd /usr/local/src/opencv/build
# cmake -DOPENCV_ENABLE_NONFREE=ON -DBUILD_EXAMPLES=ON -DBUILD_DOCS=ON -DBUILD_TESTS=ON -DBUILD_PERF_TESTS=ON .. && make install
ENV CoreAI_OPENCV_VERSION
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
