##### TensorFlow
# https://www.tensorflow.org/install/pip#linux

ENV CoreAI_TENSORFLOW_VERSION
RUN pip3 --trusted-host pypi.org --trusted-host files.pythonhosted.org install 'tensorflow[and-cuda]'==${CoreAI_TENSORFLOW_VERSION} \
    && rm -rf /root/.cache/pip

# Verify the installation:
RUN python3 -c 'import tensorflow as tf; print(f"{tf.__version__}")' > /tmp/.tensorflow_pip

RUN echo "--- Tensorflow -- PIP Installed: ${CoreAI_TENSORFLOW_VERSION}" > /tmp/tf_env.dump
