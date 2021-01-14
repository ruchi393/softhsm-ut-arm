ifeq (,$(filter $(V),1 y))
	VB			:= @
endif

ARCH				?= aarch64
# This points to the top dir for all gits used to build an working OP-TEE
# development environment.
ROOT_DIR			?= $(shell readlink -f $(CURDIR)/..)

# Make sure that we have the toolchain in the PATH
# but ONLY if path exists! Manipulating PATH to
# include non existing directories causes OE/Yocto
# builds to use the build host /usr/lib/python3
# rather than the one installed in the recipe sysroot-native
# dir when signing the TA. This subsquently causes some
# builds to fail depending on the build hosts configuration.
AARCH32_TOOLCHAIN_PATH         ?= $(ROOT_DIR)/toolchains/aarch32/bin
AARCH64_TOOLCHAIN_PATH         ?= $(ROOT_DIR)/toolchains/aarch64/bin

ifneq ($(wildcard $(AARCH32_TOOLCHAIN_PATH)/.),)
export PATH                    := $(AARCH32_TOOLCHAIN_PATH):$(PATH)
endif

ifneq ($(wildcard $(AARCH64_TOOLCHAIN_PATH)/.),)
export PATH                    := $(AARCH64_TOOLCHAIN_PATH):$(PATH)
endif

ifeq ($(ARCH), arm)
OS				?= linux
ABI				?= gnueabihf
OS_TYPE				?= 32
else ifeq ($(ARCH), aarch64)
OS				?= linux
ABI				?= gnu
OS_TYPE				?= 64
else
$(error Unknown architecture [$(ARCH)])
endif

CROSS_COMPILE 			?= $(ARCH)-$(OS)-$(ABI)-

# Paths
OPENSSL_LIB			?= $(CURDIR)/out/openssl/libcrypto.so
OUT_DIR				?= $(CURDIR)/out

CPPUNIT_BUILD_DIR		?= $(OUT_DIR)/cppunit
CPPUNIT_INSTALL_DIR		?= $(CPPUNIT_BUILD_DIR)/install
CPPUNIT_LIB_DIR			?= $(CPPUNIT_INSTALL_DIR)/lib
CPPUNIT_LIB			?= $(CPPUNIT_LIB_DIR)/libcppunit.so
CPPUNIT_INCLUDE_DIR		?= $(CPPUNIT_DIR)/cppunit/include

ifneq (, $(wildcard $(BUILDROOT_OUT)/host/bin))
# When building a Builroot file system for a standard OP-TEE developer
# setup and to avoid linker errors like "cannot find /lib/libc.so.6,
# /usr/lib/libc_nonshared.a, /lib/ld-linux-armhf.so.3", simply
# redefine the CROSS_COMPILE so it uses the same toolchain that was used when
# Buildroot was compiling libteec etc. I.e., the toolchain coming from
# Buildroot itself.
VENDOR				?= buildroot
CROSS_COMPILE 			:= $(BUILDROOT_OUT)/host/bin/$(CROSS_COMPILE)
endif

.PHONY: all
all: openssl_lib cppunit_lib softhsm_test

# Fetch all needed OpenSSL code in case it's not already there. Use a known
# file in the git as a target.
openssl/Configure:
	git submodule update --init openssl

# Fetch all needed Googletest code in case it's not already there. Use a known
# file in the git as a target.
cppunit/Configure:
	git submodule update --init cppunit

# Fetch all needed ce_cdm code in case it's not already there. Use a known
# file in the git as a target.
softhsm/test:
	git submodule update --init softhsm

################################################################################
# Googletest
################################################################################
$(CPPUNIT_LIB): cppunit/Configure
	@echo "\nBuilding CppUnitTest\n"
	$(VB)$(MAKE) -f cppunit.mk \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		OUT_DIR=${CPPUNIT_BUILD_DIR}	\
		INSTALL_DIR=${CPPUNIT_INSTALL_DIR}

cppunit_lib: $(CPPUNIT_LIB)

################################################################################
# OpenSSL
################################################################################
$(OPENSSL_LIB): openssl/Configure
ifneq ($(VB), )
	$(VB)$(MAKE) -f openssl.mk ARCH=$(OS_TYPE) --silent OUT_DIR=${OUT_DIR}/openssl
else
	$(VB)$(MAKE) -f openssl.mk ARCH=$(OS_TYPE) OUT_DIR=${OUT_DIR}/openssl
endif

openssl_lib: $(OPENSSL_LIB)

################################################################################
# Softhsm
################################################################################
softhsm_test: softhsm/test
	@echo -n "\nBuilding softhsm test for target\n"
	$(VB)$(MAKE) -f softhsm.mk \
		CROSS_COMPILE=$(CROSS_COMPILE)

################################################################################
# QEMU helper script
################################################################################
qemu_help:
	$(VB)cd scripts && ./qemu_helper.sh

################################################################################
# Cleaning
################################################################################
.PHONY: clean
clean:

.PHONY: distclean
distclean: clean
	$(VB)$(MAKE) -f softhsm.mk clean
	$(VB)$(MAKE) -f cppunit.mk  clean
	$(VB)$(MAKE) -f openssl.mk clean
