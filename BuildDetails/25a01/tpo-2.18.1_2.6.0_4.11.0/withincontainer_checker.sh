#!/bin/bash

# Expected to be run in container
if [ ! -f /.within_container ]; then
  echo "Tool expected to be ran within the container, aborting"
  exit 1
fi

destp="/tmp/python_info.txt"
echo "Python location: $(which python3)" > $destp
echo "Python version: $(python3 --version)" >> $destp
echo "" >> $destp
echo "[pip list]" >> $destp
pip3 list >> $destp

echo "" >> $destp
echo "[apt list]" >> $destp
apt list --installed >> $destp

echo "" >> $destp
echo "[system details]" >> $destp

# Ubuntu version
tmp="/etc/lsb-release"
if [ ! -f $tmp ]; then
  echo "Unable to confirm Ubuntu version, aborting"
  exit 1
fi
echo "" >> $destp
echo -n "FOUND_UBUNTU: " >> $destp
perl -ne 'print $1 if (m%DISTRIB_RELEASE=(.+)%)' $tmp >> $destp
echo "" >> $destp

if [ -f /tmp/.GPU_build ]; then
  # CUDNN version
  cudnn_inc="/usr/include/cudnn.h"
  cudnn8_inc="/usr/include/x86_64-linux-gnu/cudnn_version_v8.h"
  cudnnjn_inc="/usr/include/cudnn_version.h"
  if [ -f $cudnn8_inc ]; then
    cudnn_inc="${cudnn8_inc}"
  elif [ -f $cudnnjn_inc ]; then
    cudnn_inc="$cudnnjn_inc"
  fi
  if [ ! -f $cudnn_inc ]; then
    cudnn="Details not found"
  else
    cmj="$(sed -n 's/^#define CUDNN_MAJOR\s*\(.*\).*/\1/p' $cudnn_inc)"
    cmn="$(sed -n 's/^#define CUDNN_MINOR\s*\(.*\).*/\1/p' $cudnn_inc)"
    cpl="$(sed -n 's/^#define CUDNN_PATCHLEVEL\s*\(.*\).*/\1/p' $cudnn_inc)"
    cudnn="${cmj}.${cmn}.${cpl}"
  fi
  echo "$cudnn" > /tmp/.cudnn_found

  # CUDA version
  nvcc="/usr/local/nvidia/bin/nvcc"
  if [ ! -f $cuda_f ]; then
    cuda="Details not found"
  else
    cuda=$($nvcc --version | grep compilation | perl -ne 'print $1 if (m%V([\d\.]+)%)')
  fi
  echo "$cuda" > /tmp/.cuda_found
fi

dest="/tmp/opencv_info.txt"
if [ -f /tmp/.opencv_built ]; then
  echo "OpenCV_built: $(cat /tmp/.opencv_built)" >> $destp

  echo -n "-- Confirming OpenCV Python is installed. Version: " > $dest
  python3 -c 'import cv2; print(cv2.__version__)' >> $dest
  echo "" >> $dest
  opencv_version -v >> $dest
  if [ -f /tmp/.cudnn_found ]; then
    echo "" >> $dest
    echo "cuDNN_FOUND: $(cat /tmp/.cudnn_found)" >> $dest
  fi
fi

if [ -f /tmp/.cuda_found ]; then
  echo "CUDA_found: $(cat /tmp/.cuda_found)" >> $destp
fi

if [ -f /tmp/.cudnn_found ]; then
  echo "cuDNN_found: $(cat /tmp/.cudnn_found)" >> $destp
fi

built_pip() {
  item=$1
  base_file=$2
  built="/tmp/.${base_file}_built"
  pip="/tmp/.${base_file}_pip"
  if [ -f "$built" ]; then
    echo "${item}_built: $(cat "$built")" >> $destp
  elif [ -f "$pip" ]; then
    echo "${item}_pip: $(cat "$pip")" >> $destp
  fi
}

built_pip "TensorFlow" "tensorflow"

built_pip "FFmpeg" "ffmpeg"

built_pip "PyTorch" "torch"

built_pip "TorchVision" "torchvision"

built_pip "TorchAudio" "torchaudio"

built_pip "TorchData" "torchdata"

built_pip "TorchText" "torchtext"
