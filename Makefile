USER := $(shell stat -c "%u:%g" .)
IMAGE := riscv-kernel-builder
DOCKER_CMD := docker run -v ${PWD}:/build -w /build -u $(USER) $(IMAGE)
TOOLCHAIN_DIR := riscv-gnu-toolchain
TOOLS_DIR := /build/tools/
TOOLCHAIN_CONFIG += --prefix=$(TOOLS_DIR)

CROSS_PREFIX := $(TOOLS_DIR)/bin/riscv64-unknown-linux-gnu-
CFLAGS := ARCH=riscv CROSS_COMPILE=$(CROSS_PREFIX) -j4

DEFCONFIG := defconfig
KERNEL_TARGETS := vmlinux modules


all: $(KERNEL_TARGETS)

# KERNEL

 $(KERNEL_TARGETS): tools config

 $(KERNEL_TARGETS) $(DEFCONFIG) help:
	$(DOCKER_CMD) make -C riscv-linux -f Makefile $(CFLAGS) $@

.PHONY: config
config: linux/.config

linux/.config:
	make $(DEFCONFIG)


# TOOLCHAIN
.PHONY: toolchain toolchain_clean toolchain_distclean
toolchain toolchain_clean toolchain_distclean:
	$(DOCKER_CMD) make _$@

.PHONY: _toolchain
_toolchain: $(TOOLCHAIN_DIR)/Makefile
	make -C $(TOOLCHAIN_DIR) linux -j4

$(TOOLCHAIN_DIR)/Makefile:
	make _toolchain_config

.PHONY: _toolchain_config
_toolchain_config:
	cd $(TOOLCHAIN_DIR) && ./configure $(TOOLCHAIN_CONFIG)

.PHONY: _toolchain_clean
_toolchain_clean:
	make -C $(TOOLCHAIN_DIR) clean

.PHONY: _toolchain_distclean
_toolchain_distclean:
	-make -C $(TOOLCHAIN_DIR) distclean
	rm -f $(TOOLCHAIN_DIR)/Makefile
	rm -rf $(TOOLS_DIR)


# DOCKER
.PHONY: docker
docker: docker/Dockerfile
	docker build -t $(IMAGE) docker
