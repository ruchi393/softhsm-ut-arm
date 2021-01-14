export V		?= n

CCACHE			?= $(shell which ccache) # Don't remove this comment (space is needed)
ARCH			?= 64
OPENSSL_MAKEFILE	?= openssl/Makefile
OUT_DIR		?= $(CURDIR)/out

# Note that we invoke the build in the "openssl" subfolder, hence the need for
# "../../". I.e., the TOOLCHAIN variable is setup for the 'context'
# <optee-widevine-ref/openssl/>.
TOOLCHAIN		?= "$(CCACHE)../../toolchains/aarch$(ARCH)/bin/"


COMMON_PARAMS	?= --prefix=$(OUT_DIR) \
		   --openssldir=$(OUT_DIR)

BUILD_PARAMS		?= 
		   
ifeq ($(ARCH), 32)
CROSS_COMPILE		?= $(TOOLCHAIN)arm-linux-gnueabihf-
CONFIG_PARAMS		?= linux-generic32 -mcpu=cortex-a9  \
			   --cross-compile-prefix=$(CROSS_COMPILE)
else ifeq ($(ARCH), 64)
CROSS_COMPILE		?= $(TOOLCHAIN)aarch64-linux-gnu-
CONFIG_PARAMS		?= linux-generic64 -mcpu=cortex-a53 \
			   --cross-compile-prefix=$(CROSS_COMPILE)
else
$(error Unknown architecture [$(ARCH)])
endif

.PHONY: all
all: $(OPENSSL_MAKEFILE) libcrypto install

$(OPENSSL_MAKEFILE):
	cd openssl && \
	mkdir -p $(OUT_DIR) && \
	./Configure $(CONFIG_PARAMS) $(COMMON_PARAMS)

libcrypto: $(OPENSSL_MAKEFILE)
	$(MAKE) -C openssl $(BUILD_PARAMS)

install: libcrypto
	 $(MAKE) -C openssl install
	
.PHONY: clean
clean:
	cd openssl && git clean -xdf
