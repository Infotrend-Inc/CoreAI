# Available CoreAI Container Images
  - [CPU](#CPU)
    - [PyTorch + OpenCV](#po)
    - [TensorFlow + OpenCV](#to)
    - [TensorFlow + PyTorch + OpenCV](#tpo)
  - [GPU](#GPU)
    - [CUDA + PyTorch + OpenCV](#cpo)
    - [CUDA + TensorFlow + OpenCV](#cto)
    - [CUDA + TensorFlow + PyTorch + OpenCV](#ctpo)
## CPU
### PyTorch + OpenCV
| Docker tag | PyTorch | OpenCV | FFmpeg | Ubuntu |
| --- | --- | --- | --- | --- |
| [25b01-po-2.6.0_4.11.0](BuildDetails/25b01/po-2.6.0_4.11.0/Dockerfile) | [2.6.0+cpu (pip)](BuildDetails/25b01/po-2.6.0_4.11.0/PyTorch--Details.txt) | [4.11.0 (built)](BuildDetails/25b01/po-2.6.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25b01/po-2.6.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25b01/po-2.6.0_4.11.0/System--Details.txt) |
| [25a01-po-2.6.0_4.11.0](BuildDetails/25a01/po-2.6.0_4.11.0/Dockerfile) | [2.6.0+cpu (pip)](BuildDetails/25a01/po-2.6.0_4.11.0/PyTorch--Details.txt) | [4.11.0 (built)](BuildDetails/25a01/po-2.6.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25a01/po-2.6.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25a01/po-2.6.0_4.11.0/System--Details.txt) |

### TensorFlow + OpenCV
| Docker tag | TensorFlow | OpenCV | FFmpeg | Ubuntu |
| --- | --- | --- | --- | --- |
| [25b01-to-2.19.0_4.11.0](BuildDetails/25b01/to-2.19.0_4.11.0/Dockerfile) | [2.19.0 (pip)](BuildDetails/25b01/to-2.19.0_4.11.0/TensorFlow--Details.txt) | [4.11.0 (built)](BuildDetails/25b01/to-2.19.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25b01/to-2.19.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25b01/to-2.19.0_4.11.0/System--Details.txt) |
| [25a01-to-2.18.1_4.11.0](BuildDetails/25a01/to-2.18.1_4.11.0/Dockerfile) | [2.18.1 (pip)](BuildDetails/25a01/to-2.18.1_4.11.0/TensorFlow--Details.txt) | [4.11.0 (built)](BuildDetails/25a01/to-2.18.1_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25a01/to-2.18.1_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25a01/to-2.18.1_4.11.0/System--Details.txt) |

### TensorFlow + PyTorch + OpenCV
| Docker tag | TensorFlow | PyTorch | OpenCV | FFmpeg | Ubuntu |
| --- | --- | --- | --- | --- | --- |
| [25b01-tpo-2.19.0_2.6.0_4.11.0](BuildDetails/25b01/tpo-2.19.0_2.6.0_4.11.0/Dockerfile) | [2.19.0 (pip)](BuildDetails/25b01/tpo-2.19.0_2.6.0_4.11.0/TensorFlow--Details.txt) | [2.6.0+cpu (pip)](BuildDetails/25b01/tpo-2.19.0_2.6.0_4.11.0/PyTorch--Details.txt) | [4.11.0 (built)](BuildDetails/25b01/tpo-2.19.0_2.6.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25b01/tpo-2.19.0_2.6.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25b01/tpo-2.19.0_2.6.0_4.11.0/System--Details.txt) |
| [25a01-tpo-2.18.1_2.6.0_4.11.0](BuildDetails/25a01/tpo-2.18.1_2.6.0_4.11.0/Dockerfile) | [2.18.1 (pip)](BuildDetails/25a01/tpo-2.18.1_2.6.0_4.11.0/TensorFlow--Details.txt) | [2.6.0+cpu (pip)](BuildDetails/25a01/tpo-2.18.1_2.6.0_4.11.0/PyTorch--Details.txt) | [4.11.0 (built)](BuildDetails/25a01/tpo-2.18.1_2.6.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25a01/tpo-2.18.1_2.6.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25a01/tpo-2.18.1_2.6.0_4.11.0/System--Details.txt) |

## GPU
### CUDA + PyTorch + OpenCV
| Docker tag | CUDA | cuDNN | PyTorch | OpenCV | FFmpeg | Ubuntu |
| --- | --- | --- | --- | --- | --- | --- |
| [25b01-cpo-12.6.3_2.6.0_4.11.0](BuildDetails/25b01/cpo-12.6.3_2.6.0_4.11.0/Dockerfile) | 12.6.85 | 9.5.1 | [2.6.0+cu126 (pip)](BuildDetails/25b01/cpo-12.6.3_2.6.0_4.11.0/PyTorch--Details.txt) | [4.11.0 (built)](BuildDetails/25b01/cpo-12.6.3_2.6.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25b01/cpo-12.6.3_2.6.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25b01/cpo-12.6.3_2.6.0_4.11.0/System--Details.txt) |
| [25a01-cpo-12.6.3_2.6.0_4.11.0](BuildDetails/25a01/cpo-12.6.3_2.6.0_4.11.0/Dockerfile) | 12.6.85 | 9.5.1 | [2.6.0+cu126 (pip)](BuildDetails/25a01/cpo-12.6.3_2.6.0_4.11.0/PyTorch--Details.txt) | [4.11.0 (built)](BuildDetails/25a01/cpo-12.6.3_2.6.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25a01/cpo-12.6.3_2.6.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25a01/cpo-12.6.3_2.6.0_4.11.0/System--Details.txt) |

### CUDA + TensorFlow + OpenCV
| Docker tag | CUDA | cuDNN | TensorFlow | OpenCV | FFmpeg | Ubuntu |
| --- | --- | --- | --- | --- | --- | --- |
| [25b01-cto-12.6.3_2.19.0_4.11.0](BuildDetails/25b01/cto-12.6.3_2.19.0_4.11.0/Dockerfile) | 12.6.85 | 9.5.1 | [2.19.0 (pip)](BuildDetails/25b01/cto-12.6.3_2.19.0_4.11.0/TensorFlow--Details.txt) | [4.11.0 (built)](BuildDetails/25b01/cto-12.6.3_2.19.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25b01/cto-12.6.3_2.19.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25b01/cto-12.6.3_2.19.0_4.11.0/System--Details.txt) |
| [25a01-cto-12.6.3_2.18.1_4.11.0](BuildDetails/25a01/cto-12.6.3_2.18.1_4.11.0/Dockerfile) | 12.6.85 | 9.5.1 | [2.18.1 (pip)](BuildDetails/25a01/cto-12.6.3_2.18.1_4.11.0/TensorFlow--Details.txt) | [4.11.0 (built)](BuildDetails/25a01/cto-12.6.3_2.18.1_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25a01/cto-12.6.3_2.18.1_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25a01/cto-12.6.3_2.18.1_4.11.0/System--Details.txt) |

### CUDA + TensorFlow + PyTorch + OpenCV
| Docker tag | CUDA | cuDNN | TensorFlow | PyTorch | OpenCV | FFmpeg | Ubuntu |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [25b01-ctpo-12.6.3_2.19.0_2.6.0_4.11.0](BuildDetails/25b01/ctpo-12.6.3_2.19.0_2.6.0_4.11.0/Dockerfile) | 12.6.85 | 9.5.1 | [2.19.0 (pip)](BuildDetails/25b01/ctpo-12.6.3_2.19.0_2.6.0_4.11.0/TensorFlow--Details.txt) | [2.6.0+cu126 (pip)](BuildDetails/25b01/ctpo-12.6.3_2.19.0_2.6.0_4.11.0/PyTorch--Details.txt) | [4.11.0 (built)](BuildDetails/25b01/ctpo-12.6.3_2.19.0_2.6.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25b01/ctpo-12.6.3_2.19.0_2.6.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25b01/ctpo-12.6.3_2.19.0_2.6.0_4.11.0/System--Details.txt) |
| [25a01-ctpo-12.6.3_2.18.1_2.6.0_4.11.0](BuildDetails/25a01/ctpo-12.6.3_2.18.1_2.6.0_4.11.0/Dockerfile) | 12.6.85 | 9.5.1 | [2.18.1 (pip)](BuildDetails/25a01/ctpo-12.6.3_2.18.1_2.6.0_4.11.0/TensorFlow--Details.txt) | [2.6.0+cu126 (pip)](BuildDetails/25a01/ctpo-12.6.3_2.18.1_2.6.0_4.11.0/PyTorch--Details.txt) | [4.11.0 (built)](BuildDetails/25a01/ctpo-12.6.3_2.18.1_2.6.0_4.11.0/OpenCV--Details.txt) | [7.1.1 (built)](BuildDetails/25a01/ctpo-12.6.3_2.18.1_2.6.0_4.11.0/FFmpeg--Details.txt) | [24.04](BuildDetails/25a01/ctpo-12.6.3_2.18.1_2.6.0_4.11.0/System--Details.txt) |

