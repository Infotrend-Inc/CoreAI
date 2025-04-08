##### Torch (using FFMpeg + OpenCV + Magma [GPU only])

ENV CoreAI_TORCH_CUDA_ARCH

ENV CoreAI_TORCH=2.0.1
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
ENV CoreAI_TORCHVISION=0.15.2
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

ENV CoreAI_TORCHAUDIO=2.0.2
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

ENV CoreAI_TORCHDATA=0.6.1
RUN mkdir -p /usr/local/src \
  && cd /usr/local/src \
  && git clone --depth 1 --recurse-submodule --branch v${CoreAI_TORCHDATA} https://github.com/pytorch/data.git  \
  && cd /usr/local/src/data \
  && BUILD_VERSION=${CoreAI_TORCHDATA} pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install . | tee /tmp/torchdata_config.txt \
  && rm -rf /root/.cache/pip /usr/local/src/data

RUN python3 -c 'import torchdata; print(f"{torchdata.__version__}")' > /tmp/.torchdata_built
