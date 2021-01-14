export V	?= n

ARCH		?= 64

OUT_DIR		?= $(CURDIR)/out
SOFTHSM_PATH    ?= $(CURDIR)/softhsm

COMMON_PARAMS	?= CPPFLAGS="-fPIC" \
		   CFLAGS="-g -O2 -fPIC" \
		   LDFLAGS="-fPIC"	\
		   --disable-p11-kit --with-openssl=$(OUT_DIR)/openssl \
		   CPPUNIT_CFLAGS=-I$(OUT_DIR)/cppunit/install/include CPPUNIT_LIBS="-L$(OUT_DIR)/cppunit/install/lib -lcppunit"


ifeq ($(ARCH), 32)
CROSS_COMPILE	?= arm-linux-gnueabihf-
CONFIG_PARAMS	?= --host=arm-linux-gnueabihf
else ifeq ($(ARCH), 64)
CONFIG_PARAMS	?= --host=aarch64-linux-gnu
else
$(error Unknown architecture [$(ARCH)])
endif

.PHONY: all
all: autogen configure softhsmunit

autogen:
	cd $(SOFTHSM_PATH) && ./autogen.sh

configure: autogen
	mkdir -p $(OUT_DIR)/softhsm && \
	cd $(OUT_DIR)/softhsm && \
	$(SOFTHSM_PATH)/configure $(CONFIG_PARAMS) $(COMMON_PARAMS)

softhsmunit: configure
	$(MAKE) -C $(OUT_DIR)/softhsm/src/lib/test  p11test_DEPENDENCIES= p11test_LDADD= CPPFLAGS=-DP11M=\\\"/usr/lib/libckteec.so\\\" p11test

.PHONY: clean
clean:
	rm -rf $(OUT_DIR) && \
	cd $(SOFTHSM_PATH) && git clean -xdf
