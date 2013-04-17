#/bin/sh

# Check if the binary exists.
if [ -f "lib/libluajit.a" ]; then
    exit 0
fi

if [ ! -d lib/temp ]; then
    mkdir -p lib/temp
fi

IXCODE=`xcode-select -print-path`

# Build for MacOS (x86_64)
ISDK=$IXCODE/Platforms/MacOSX.platform/Developer
ISDKVER=MacOSX10.8.sdk
ISDKP=$ISDK/usr/bin/
ISDKF="-arch x86_64 -isysroot $ISDK/SDKs/$ISDKVER"
make clean
make TARGET_FLAGS="-arch x86_64"
mv src/libluajit.a lib/temp/libluajit-macos-x86_64.a

# Build for iOS device (armv7)
ISDK=$IXCODE/Platforms/iPhoneOS.platform/Developer
ISDKVER=iPhoneOS6.1.sdk
ISDKP=$ISDK/usr/bin/
ISDKF="-arch armv7 -isysroot $ISDK/SDKs/$ISDKVER"
make clean
make HOST_CC="gcc -m32 -arch i386" CROSS=$ISDKP TARGET_FLAGS="$ISDKF" \
     TARGET_SYS=iOS
mv src/libluajit.a lib/temp/libluajit-ios-armv7.a

# Build for iOS device (armv7s)
ISDKF="-arch armv7s -isysroot $ISDK/SDKs/$ISDKVER"
make clean
make HOST_CC="gcc -m32 -arch i386" CROSS=$ISDKP TARGET_FLAGS="$ISDKF" \
     TARGET_SYS=iOS
mv src/libluajit.a lib/temp/libluajit-ios-armv7s.a

# Build for iOS simulator
ISDK=$IXCODE/Platforms/iPhoneSimulator.platform/Developer
ISDKVER=iPhoneSimulator6.1.sdk
ISDKP=$ISDK/usr/bin/
ISDKF="-arch i386 -isysroot $ISDK/SDKs/$ISDKVER"
make clean
make HOST_CFLAGS="-arch i386" HOST_LDFLAGS="-arch i386" TARGET_SYS=iOS TARGET=x86 CROSS=$ISDKP TARGET_FLAGS="$ISDKF" \
     TARGET_SYS=iOS
mv src/libluajit.a lib/temp/libluajit-simulator.a

# Combine all archives to one.
libtool -o lib/libluajit.a lib/temp/*.a 2> /dev/null
rm -rf lib/temp
make clean
