FROM ubuntu:latest

# Install dependencies
RUN apt update && apt install -y \
    wget \
    git \
    build-essential \
    device-tree-compiler \
    libboost-regex-dev \
    libboost-system-dev && rm -rf /var/lib/apt/lists/*

# Download the RISC-V toolchain
RUN wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2024.03.01/riscv64-elf-ubuntu-22.04-gcc-nightly-2024.03.01-nightly.tar.gz \
    && mkdir -p /opt/cross/ \
    && tar -xvf riscv64-elf-ubuntu-22.04-gcc-nightly-2024.03.01-nightly.tar.gz -C /opt/cross --strip-components=1 \
    && rm riscv64-elf-ubuntu-22.04-gcc-nightly-2024.03.01-nightly.tar.gz

# Add the toolchain to the PATH
ENV PATH="/opt/cross/bin:${PATH}"

# Install and build RISC-V Spike simulator
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim.git spike \
    && cd spike \
    && mkdir build && cd build && ../configure --prefix=/opt/cross \
    && make -j$(nproc) \
    && make install \
    && cd ../../ && rm -rf spike

# Install and build RISC-V Proxy Kernel (pk)
RUN git clone https://github.com/riscv-software-src/riscv-pk \
    && cd riscv-pk \
    && mkdir build && cd build && ../configure --prefix=/opt/cross  --host=riscv64-unknown-elf \
    && make -j$(nproc) \
    && make install \
    && cd ../../ && rm -rf riscv-pk

WORKDIR /workspace
COPY . /workspace

# Build the test harness
RUN make exe

# Command to run tests
CMD ["make", "run"]