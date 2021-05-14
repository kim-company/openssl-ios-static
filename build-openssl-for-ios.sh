#!/bin/bash

# Made by KIM Keep In Mind GmbH, 2021
# Script to build iOS OpenSSL
# Made for building recent iOS versions arm64, x86_64
# BigSur and Xcode 12+ tested. 

## Variables
OPENSSL_VERSION=1.1.1k

##############################
### BUILD SCRIPT #############
##############################

echo "Download OpenSSL: ${OPENSSL_VERSION}"
curl -O https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
tar xf openssl-${OPENSSL_VERSION}.tar.gz && rm -rf openssl-${OPENSSL_VERSION}.tar.gz

# We need absolute path
TMP_DIR="`pwd`/build_openssl"
CROSS_TOP_SIM="`xcode-select --print-path`/Platforms/iPhoneSimulator.platform/Developer"
CROSS_SDK_SIM="iPhoneSimulator.sdk"
CROSS_TOP_IOS="`xcode-select --print-path`/Platforms/iPhoneOS.platform/Developer"
CROSS_SDK_IOS="iPhoneOS.sdk"

# Change to OpenSSL directory
cd openssl-${OPENSSL_VERSION}
export CROSS_COMPILE=`xcode-select --print-path`/Toolchains/XcodeDefault.xctoolchain/usr/bin/

function build_for ()
{
  PLATFORM=$1
  ARCH=$2
  CROSS_TOP_ENV=CROSS_TOP_$3
  CROSS_SDK_ENV=CROSS_SDK_$3

  echo "Building Open SSL for ${ARCH}"
  if [ -f "configdata.pm" ]; then
    make clean
  fi
  
  export CROSS_TOP="${!CROSS_TOP_ENV}"
  export CROSS_SDK="${!CROSS_SDK_ENV}"
  ./Configure $PLATFORM "-arch $ARCH -fembed-bitcode" no-asm no-shared no-hw no-async --prefix=${TMP_DIR}/${ARCH} || exit 1
  make && make install_sw || exit 2
  unset CROSS_TOP
  unset CROSS_SDK
}

function pack_for ()
{
  LIBNAME=$1
  mkdir -p ${TMP_DIR}/lib/
  ${DEVROOT}/usr/bin/lipo \
	${TMP_DIR}/x86_64/lib/lib${LIBNAME}.a \
	${TMP_DIR}/arm64/lib/lib${LIBNAME}.a \
	-output ${TMP_DIR}/lib/lib${LIBNAME}.a -create
}

patch Configurations/10-main.conf << "EOF"
diff --git a/Configurations/10-main.conf b/Configurations/10-main.conf
--- a/Configurations/10-main.conf
+++ b/Configurations/10-main.conf
@@ -1640,6 +1640,13 @@ my %targets = (
         sys_id           => "VXWORKS",
         lflags           => add("-r"),
     },
+    "ios64sim-cross" => {
+        inherit_from     => [ "darwin-common", asm("no_asm") ],
+        cflags           => add("-arch x86_64 -DOPENSSL_NO_ASM -mios-version-min=9.0.0 -isysroot \$(CROSS_TOP)/SDKs/\$(CROSS_SDK) -fno-common"),
+        sys_id           => "iOS",
+        bn_ops           => "SIXTY_FOUR_BIT_LONG RC4_CHAR",
+        perlasm_scheme   => "ios64",
+    },
     "vxworks-simlinux" => {
         inherit_from     => [ "BASE_unix" ],
         CC               => "ccpentium",
EOF

echo "Start Building OpenSSL... "
build_for ios64sim-cross x86_64 SIM || exit 2
build_for ios64-cross arm64 IOS || exit 3

echo "Building FAT binary release version"
pack_for ssl || exit 4
pack_for crypto || exit 5
echo "  |> copy header files"
cp -r ${TMP_DIR}/arm64/include $TMP_DIR/lib/

echo "Build-Script is done."