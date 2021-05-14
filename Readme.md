# Build OpenSSL for iOS
This repository helps everyone to build OpenSSL for iOS. OpenSSL is used in many projects and if you need to build libraries from sourcecode the self compiled OpenSSL version is useful - sometimes absolutely necessary. 

## How to
Choose option 1 or option 2. Builds for `arm64` are for iOS devices and Apple Silicon CPUs, `x86_64` are for Intel CPU Macs and iOS Simulators on Intel Macs. 

### Option 1
1. Use the precompiled static libraries we have compiled. Look into [static-build folder](static-builds) and download the version you need. 

### Option 2
1. Check the requirements
    * macOS BigSur or newer
    * Xcode 12 or newer
    * APFS formatted HDD
1. Download the script [build-openssel-for-ios.sh](build-openssl-for-ios.sh) and run it by calling `./build-openssel-for-ios.sh`
2. It will create an folder called `build_openssl` that will contain the files:
   * `build_openssl/arm64` for iOS usage
   * `build_openssl/x68_64` for iOS Simulator usage

## Note
If you want to check a library like `libcrypto.a` on which platform it's running or made for, then just run this command: 
`lipo -info libcrypto.a` and it will tell you. 

