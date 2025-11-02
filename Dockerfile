# syntax=docker/dockerfile:1.4
FROM nvidia/cuda:12.6.1-cudnn-devel-ubuntu22.04

# Set default RUN shell to /bin/bash
SHELL ["/bin/bash", "-cu"]


# Set environment variables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8


# Install basic packages for compiling and building
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
    build-essential \
    cmake \
    g++-12 \
    git \
    git-lfs \
    curl \
    wget \
    ca-certificates \
    libjpeg-dev \
    libpng-dev \
    librdmacm1 \
    libibverbs1 \
    ibverbs-providers \
    tzdata \
    libgl1-mesa-glx \
    libglib2.0-0 \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*


# Install Miniconda & use Python 3.11
ARG python=3.10
ENV PYTHON_VERSION=${python}
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/install-conda.sh \
    && chmod +x /tmp/install-conda.sh \
    && bash /tmp/install-conda.sh -b -f -p /usr/local \
    && rm -f /tmp/install-conda.sh \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r \
    && conda install -y python=${PYTHON_VERSION} \
    && conda clean -y --all

# Configure conda and pip mirrors for faster installation
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN cat <<EOT >> ~/.condarc
channels:
  - defaults
show_channel_urls: true
channel_alias: https://mirrors.tuna.tsinghua.edu.cn/anaconda
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/pro
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  nvidia: https://mirrors.sustech.edu.cn/anaconda-extra/cloud
EOT


# Install Pytorch 2.2
# you can find other versions and installation commands from:
# https://pytorch.org/get-started/previous-versions/
# https://github.com/pytorch/pytorch/wiki/PyTorch-Versions
# RUN pip install --no-cache-dir \
#     torch==2.2.1 \
#     --extra-index-url https://download.pytorch.org/whl/cu118
ENV TORCH_CUDA_ARCH_LIST="8.0;9.0"
RUN /usr/local/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && /usr/local/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r \
    && /usr/local/bin/conda tos accept --override-channels --channel https://conda.anaconda.org/pytorch \
    && /usr/local/bin/conda tos accept --override-channels --channel https://conda.anaconda.org/conda-forge
RUN pip install --no-cache-dir \
    torch==2.7.1 --index-url https://download.pytorch.org/whl/cu126

COPY . /workspace
RUN pip install --no-cache-dir /workspace[cuda]

WORKDIR /workspace

CMD ["bash"]
