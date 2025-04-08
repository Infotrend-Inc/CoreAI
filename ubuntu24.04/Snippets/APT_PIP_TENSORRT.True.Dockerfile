
RUN apt-get install -y \
    tensorrt \
    tensorrt-dev \
    tensorrt-libs \
  && apt-get clean

RUN pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install -U --ignore-installed \
    tensorrt \
  && rm -rf /root/.cache/pip