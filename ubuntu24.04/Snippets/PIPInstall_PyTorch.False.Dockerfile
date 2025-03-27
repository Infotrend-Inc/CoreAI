# No PyTorch, Torch Audio or Torch Video
RUN echo "No PyTorch PIP installed" > /tmp/torch_config.txt \
  && echo "No TorchVision PIP installed" > /tmp/torchvision_config.txt \
  && echo "No TorchAudio PIP installed" > /tmp/torchaudio_config.txt \
  && echo "No TorchData PIP installed" > /tmp/torchdata_config.txt \
  && echo "No TorchText PIP installed" > /tmp/torchtext_config.txt
