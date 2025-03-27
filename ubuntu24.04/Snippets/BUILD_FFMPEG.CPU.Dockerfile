##### FFMPEG

ENV CoreAI_FFMPEG_VERSION="4.4.2"
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
