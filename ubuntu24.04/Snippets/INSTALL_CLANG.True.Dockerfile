ENV CoreAI_CLANG_VERSION=16
RUN apt-get install -y lsb-release software-properties-common gnupg \
  && mkdir /tmp/clang \
  && cd /tmp/clang \
  && wget https://apt.llvm.org/llvm.sh \
  && chmod +x llvm.sh \
  && ./llvm.sh ${CoreAI_CLANG_VERSION} \
  && cd / \
  && rm -rf /tmp/clang
RUN which clang-${CoreAI_CLANG_VERSION} \
  && which clang++-${CoreAI_CLANG_VERSION} \
  && clang-${CoreAI_CLANG_VERSION} --version \
  && clang++-${CoreAI_CLANG_VERSION} --version