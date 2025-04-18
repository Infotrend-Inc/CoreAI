##### FFMPEG

ENV CoreAI_FFMPEG_VERSION="4.4.2"
ENV CoreAI_FFMPEG_NVCODEC="11.1.5.1"
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