FROM ubuntu:jammy

ENV TZ=america/los_angeles

# Install prerequisite packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install --no-install-recommends -q -y \
    apt-utils \
    software-properties-common \
    gnupg \
    wget \
    ocl-icd-libopencl1 \
    git \
    ffmpeg

# Defect Workground #1: GPU apt repo userspace driver does not support Kernel 6.8, so install directly from their repo
# https://github.com/intel/compute-runtime/issues/710
RUN cd /tmp && \
  wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.16510.2/intel-igc-core_1.0.16510.2_amd64.deb && \
  wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.16510.2/intel-igc-opencl_1.0.16510.2_amd64.deb && \
  wget https://github.com/intel/compute-runtime/releases/download/24.13.29138.7/intel-level-zero-gpu_1.3.29138.7_amd64.deb && \
  wget https://github.com/intel/compute-runtime/releases/download/24.13.29138.7/intel-opencl-icd_24.13.29138.7_amd64.deb && \
  wget https://github.com/intel/compute-runtime/releases/download/24.13.29138.7/libigdgmm12_22.3.18_amd64.deb && \
  dpkg -i *.deb 

# Install Intel GPU user-space driver apt repo 
RUN wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
   gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg && \
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | \
   tee /etc/apt/sources.list.d/intel-gpu-jammy.list

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install --no-install-recommends -q -y \
     level-zero 

# Install oneAPI
RUN wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
   gpg --dearmor --output /usr/share/keyrings/oneapi-archive-keyring.gpg && \ 
   echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
   tee /etc/apt/sources.list.d/oneAPI.list

# Install Python 
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install --no-install-recommends -q -y \
    python3 \
    python3-pip \
    intel-basekit=2024.0.1-43 && \
    pip3 install --pre --upgrade ipex-llm[xpu] --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us && \
    pip3 install einops

#Defect Workaround #2: Transfers package not compatible with oneAPI basekit
#https://github.com/pytorch/pytorch/issues/123097#issuecomment-2050934427
RUN pip3 install torch==2.1.0.post0 torchvision==0.16.0.post0 torchaudio==2.1.0.post0 intel-extension-for-pytorch==2.1.20+xpu oneccl_bind_pt==2.1.200+xpu --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ && \
   pip3 install transformers==4.37

ENV USE_XETLA=OFF
ENV SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS=1
ENV SYCL_CACHE_PERSISTENT=1

RUN mkdir /workspace && \
   cd /workspace && \
   git clone -b enable-intel-gpu https://github.com/mattcurf/whisper && \
   cd whisper && \
   pip install -r requirements.txt 

COPY _run.sh /usr/share/lib/run_workspace.sh

ENTRYPOINT ["/bin/bash", "/usr/share/lib/run_workspace.sh"]
