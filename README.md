# build-riscv-kernel
A simple docker-based build for cross-compiling a riscv Linux kernel


## Setup
Initialize submodules:

`git submodule update --init --recursive`

If selinux is in use, set the context for use with the container:

`chcon -Rt svirt_sandbox_file_t path`


## Docker Image
`make docker`


## Toolchain
`make toolchain`
