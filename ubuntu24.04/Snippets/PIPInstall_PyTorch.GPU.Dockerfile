##### Torch 

ENV CoreAI_TORCH=1.11
ENV CoreAI_TORCHVISION=0.12
ENV CoreAI_TORCHAUDIO=0.11
ENV CoreAI_TORCHDATA=0.6.1
ENV CoreAI_TORCH_WHEEL=

RUN pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org torch==${CoreAI_TORCH} torchvision==${CoreAI_TORCHVISION} torchaudio==${CoreAI_TORCHAUDIO} --index-url https://download.pytorch.org/whl/${CoreAI_TORCH_WHEEL} \
    && rm -rf /root/.cache/pip

RUN echo "--- PyTorch: PIP Installed" | tee /tmp/torch_config.txt | tee /tmp/torchvision_config.txt | tee /tmp/torchaudio_config.txt | tee /tmp/torchdata_config.txt
RUN python3 -c 'import torch; print(f"{torch.__version__}")' | tee -a /tmp/torch_config.txt | tee /tmp/.torch_pip
RUN python3 -c 'import torchvision; print(f"{torchvision.__version__}")' | tee -a /tmp/torchvision_config.txt | tee /tmp/.torchvision_pip
RUN python3 -c 'import torchaudio; print(f"{torchaudio.__version__}")' | tee -a /tmp/torchaudio_config.txt | tee /tmp/.torchaudio_pip

RUN pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install torchdata==${CoreAI_TORCHDATA} \
    && rm -rf /root/.cache/pip

RUN python3 -c 'import torchdata; print(f"{torchdata.__version__}")' | tee -a /tmp/torchdata_config.txt | tee /tmp/.torchdata_pip
