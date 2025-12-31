# tools/docker/Dockerfile
FROM debian:bookworm-slim

# Install the dependencies necessary to build Binutils and GCC
RUN apt-get update && apt-get install -y\ 
    build-essential\ 
    bison\ 
    flex\ 
    libgmp3-dev\ 
    libmpc-dev\ 
    libmpfr-dev\ 
    texinfo\ 
    curl\ 
    wget\ 
    file\ 
    && rm -rf /var/lib/apt/lists/*

# Preparing space for the toolchain
RUN mkdir -p /root/opt/cross
ENV PATH="/root/opt/cross/bin:${PATH}"

WORKDIR /root/os-project