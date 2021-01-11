#!/usr/bin/env bash

SOFTHSM_ABSPATH=`dirname ${PWD}`
SOFTHSM_DIRNAME=`basename ${SOFTHSM_ABSPATH}`

TESTBIN=p11test
LIBOPENSSL=libcrypto.so.3
LIBCPPUNIT=libcppunit-1.15.so.1

# Links relative to the root dir
OUT=${SOFTHSM_DIRNAME}/out
OPENSSL_LIB="${OUT}/openssl/lib/${LIBOPENSSL}"
CPPUNIT_LIB="${OUT}/cppunit/install/lib/${LIBCPPUNIT}"
SOFTHSM_TEST="${OUT}/softhsm/src/lib/test/${TESTBIN}"

echo -e "\nMount alias on device / QEMU:"

# Start creating individual commands for the final alias
START="   alias setup_softhsmtest='"

# Mount the host PC
CMD_1="mkdir -p /host"
CMD_2="mount -t 9p -o trans=virtio host /host"

# Add symlink to the library
CMD_3="ln -sf /host/${OPENSSL_LIB} /usr/lib/"
CMD_4="ln -sf /host/${CPPUNIT_LIB} /usr/lib/"

# Add symlink to widevine_ce_cdm_unittest
CMD_5="ln -sf /host/${SOFTHSM_TEST} /usr/bin/"

END="'"

# To print the commands one by one, add "debug" as argument when calling this
# script.
if [[ $1 == "debug" ]]; then
	echo "START: ${START}"
	echo "CMD_1: ${CMD_1}"
	echo "CMD_2: ${CMD_2}"
	echo "CMD_3: ${CMD_3}"
	echo "CMD_4: ${CMD_4}"
	echo "CMD_5: ${CMD_5}"
	echo "END:   ${END}"
fi

# Construct the final alias line.
echo "${START}${CMD_1} && ${CMD_2} && ${CMD_3} && ${CMD_4} && ${CMD_5}${END}"
