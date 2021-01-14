export V	?= n

ARCH		?= 64

OUT_DIR		?= $(CURDIR)/out/cppunit
INSTALL_DIR	?= $(OUT_DIR)/cppunit
CPPUNIT_PATH    ?= $(CURDIR)/cppunit

COMMON_PARAMS	?= --prefix=$(OUT_DIR)/install \
		   CPPFLAGS="-fPIC" \
		   CFLAGS="-g -O2 -fPIC" \
		   LDFLAGS="-fPIC"

ifeq ($(ARCH), 32)
CROSS_COMPILE	?= arm-linux-gnueabihf-
CONFIG_PARAMS	?= --host=arm-linux-gnueabihf
else ifeq ($(ARCH), 64)
CONFIG_PARAMS	?= --host=aarch64-linux-gnu
else
$(error Unknown architecture [$(ARCH)])
endif

.PHONY: all
all: autogen configure cppunit install

autogen:
	cd $(CPPUNIT_PATH) && ./autogen.sh

configure: autogen
	mkdir -p $(OUT_DIR) && \
	cd $(OUT_DIR) && \
	$(CPPUNIT_PATH)/configure $(CONFIG_PARAMS) $(COMMON_PARAMS)

cppunit: configure
	$(MAKE) -C $(OUT_DIR)

install: cppunit
	mkdir -p $(OUT_DIR)/install && \
	$(MAKE) -C $(OUT_DIR) install

.PHONY: clean
clean:
	rm -rf $(OUT_DIR) && \
	cd $(CPPUNIT_PATH) && git clean -xdf
