##### TensorFlow
# https://www.tensorflow.org/install/source

## Download & Building TensorFlow from source in same RUN
ENV LATEST_BAZELISK=
ENV CoreAI_TENSORFLOW_VERSION
ENV CoreAI_TF_CONFIG=""
ENV TF_CUDA_COMPUTE_CAPABILITIES=""

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
