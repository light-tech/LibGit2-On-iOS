export REPO_ROOT=`pwd`
export PATH=$PATH:$REPO_ROOT/tools/bin

# Download build tools
test -d tools || wget https://github.com/light-tech/LLVM-On-iOS/releases/download/llvm12.0.0/tools.tar.xz
tar xzf tools.tar.xz

### Setup common environment variables to run CMake for a given platform
### Usage:      setup_variables PLATFORM
### where PLATFORM is the platform to build for and should be one of
###    iphoneos            (for now implicitly arm64)
###    iphonesimulator     (for now implicitly x86_64)
###    maccatalyst         (for now implicitly x86_64)
### (macos and M1 macos to be added in the future)
###
### After this function is executed, the variable $PLATFORM and $CMAKE_ARGS
### providing basic/common CMake options will be set.
###
function setup_variables() {
	cd $REPO_ROOT
	echo "Setup variables " $1
	PLATFORM=$1

	CMAKE_ARGS=(-DBUILD_SHARED_LIBS=NO -DCMAKE_BUILD_TYPE=Release)

	case $PLATFORM in
		"iphoneos")
			SYSROOT=`xcodebuild -version -sdk iphoneos Path`
			echo $SYSROOT
			CMAKE_ARGS+=("-DCMAKE_C_COMPILER_WORKS=ON" "-DCMAKE_CXX_COMPILER_WORKS=ON" "-DCMAKE_OSX_ARCHITECTURES=arm64" "-DCMAKE_OSX_SYSROOT=$SYSROOT");;
		"iphonesimulator")
			SYSROOT=`xcodebuild -version -sdk iphonesimulator Path`
			echo $SYSROOT
			CMAKE_ARGS+=("-DCMAKE_OSX_SYSROOT=$SYSROOT");;
		"maccatalyst")
			# No need to set up SYSROOT as CMake should find MacOS SDK automatically
			echo "Set up variables for Mac Catalyst";;
		*)
			echo "Unsupported or missing platform!"
			echo "Usage: setup_variables [iphoneos|iphonesimulator|maccatalyst]";;
	esac
	echo "Done setup variables!"
}

### Build libgit2 for a single platform (given as the first and only argument)
### See @setup_variables for the list of available platform names
###
function build_libgit2() {
	setup_variables $1

	# test -d libgit2 || git clone --recursive https://github.com/libgit2/libgit2.git
	# cd libgit2
	# git submodule update --recursive

	test -d libgit2-1.1.0 || wget https://github.com/libgit2/libgit2/releases/download/v1.1.0/libgit2-1.1.0.tar.gz && tar xzf libgit2-1.1.0.tar.gz
	cd libgit2-1.1.0

	rm -rf build && mkdir build && cd build

	# See libgit2/cmake/FindPkgLibraries.cmake
	CMAKE_ARGS+=(-DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/libgit2-$PLATFORM \
		-DUSE_SSH=ON \
		-DLIBSSH2_FOUND=YES \
		-DLIBSSH2_INCLUDE_DIRS=$REPO_ROOT/install/libssh2-$PLATFORM \
		-DBUILD_CLAR=NO)

	case $PLATFORM in
		"iphoneos"|"iphonesimulator")
			cmake ${CMAKE_ARGS[@]} ..;;
		"maccatalyst")
			cmake ${CMAKE_ARGS[@]} -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" ..;;
	esac

	cmake --build . --target install
}

### Build Clibgit2 xcframework
### Usage: build_libgit2_xcframework LIST_OF_PLATFORMS
### See @setup_variables for the list of available platform names
### Example: build_libgit2_xcframework iphoneos maccatalyst
###
function build_libgit2_xcframework() {
	cd $REPO_ROOT
	PLATFORMS=( "$@" )
	FRAMEWORKS_ARGS=()

	for p in ${PLATFORMS[@]}; do
		build_libgit2 $p
		FRAMEWORKS_ARGS+=("-library" "install/libgit2-$p/lib/libgit2.a" "-headers" "install/libgit2-$p/include")
	done

	cd $REPO_ROOT
	xcodebuild -create-xcframework ${FRAMEWORKS_ARGS[@]} -output libgit2.xcframework

	# Copy the module.modulemap so we can use the framework in Swift
	FWDIRS=$(find libgit2.xcframework -mindepth 1 -maxdepth 1 -type d)
	for d in ${FWDIRS[@]}; do
		echo $d
		cp module.modulemap $d/Headers/
	done

	tar -cJf libgit2.xcframework.tar.xz libgit2.xcframework
}

### Build libpcre for a single platform
### See @setup_variables for the list of available platform names
###
function build_pcre() {
	setup_variables $1

	test -d pcre-8.44 || wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz && tar xzf pcre-8.44.tar.gz # https://ftp.pcre.org/pub/pcre/pcre2-10.36.tar.gz
	cd pcre-8.44

	rm -rf build && mkdir build && cd build
	CMAKE_ARGS+=(-DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/pcre-$PLATFORM \
		-DPCRE_BUILD_PCRECPP=NO \
		-DPCRE_BUILD_PCREGREP=NO \
		-DPCRE_BUILD_TESTS=NO \
		-DPCRE_SUPPORT_LIBBZ2=NO)

	echo ${CMAKE_ARGS[@]}

	case $PLATFORM in
		"iphoneos"|"iphonesimulator")
			cmake ${CMAKE_ARGS[@]} ..;;
		"maccatalyst")
			cmake ${CMAKE_ARGS[@]} -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" ..;;
	esac

	cmake --build . --target install
}

### Build PCRE xcframework
### Usage: build_pcre_framework LIST_OF_PLATFORMS
### See @setup_variables for the list of available platform names
###
function build_pcre_xcframework() {
	cd $REPO_ROOT
	PLATFORMS=( "$@" )
	FRAMEWORKS_ARGS=()

	for p in ${PLATFORMS[@]}; do
		build_pcre $p
		FRAMEWORKS_ARGS+=("-library" "install/pcre-$p/lib/libpcre.a" "-headers" "install/pcre-$p/include")
	done

	cd $REPO_ROOT
	xcodebuild -create-xcframework ${FRAMEWORKS_ARGS[@]} -output pcre.xcframework
	tar -cJf pcre.xcframework.tar.xz pcre.xcframework
}

function build_openssl() {
	setup_variables $1

	# It is better to remove and redownload the source since building make the source code directory dirty!
	rm -rf openssl-OpenSSL_1_1_1k
	test -f OpenSSL_1_1_1k.tar.gz || wget https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1k.tar.gz
	tar xzf OpenSSL_1_1_1k.tar.gz
	cd openssl-OpenSSL_1_1_1k

	case $PLATFORM in
		"iphoneos")
			SYSROOT=`xcodebuild -version -sdk iphoneos Path`
			TARGET_OS=ios64-cross
			export CFLAGS="-isysroot $SYSROOT -arch arm64";;
		"iphonesimulator")
			SYSROOT=`xcodebuild -version -sdk iphonesimulator Path`
			TARGET_OS=iossimulator-xcrun
			export CFLAGS="-isysroot $SYSROOT";;
		"maccatalyst")
			SYSROOT=`xcodebuild -version -sdk macosx Path`
			TARGET_OS=darwin64-x86_64-cc
			export CFLAGS="-isysroot $SYSROOT -target x86_64-apple-ios14.1-macabi";;
		*)
			echo "Unsupported or missing platform!";;
	esac

	# See https://wiki.openssl.org/index.php/Compilation_and_Installation
	./Configure --prefix=$REPO_ROOT/install/openssl-$PLATFORM \
		--openssldir=$REPO_ROOT/install/openssl-$PLATFORM \
		$TARGET_OS no-shared no-dso no-hw no-engine

	make
	make install

	# Merge two static libraries libssl.a and libcrypto.a into a single openssl.a since XCFramework does not allow multiple *.a
	cd $REPO_ROOT/install/openssl-$PLATFORM/lib
	libtool -static -o openssl.a *.a
}

function build_openssl_xcframework() {
	cd $REPO_ROOT
	PLATFORMS=( "$@" )
	FRAMEWORKS_ARGS=()

	for p in ${PLATFORMS[@]}; do
		build_openssl $p
		FRAMEWORKS_ARGS+=("-library" "install/openssl-$p/lib/openssl.a" "-headers" "install/openssl-$p/include")
	done

	cd $REPO_ROOT
	xcodebuild -create-xcframework ${FRAMEWORKS_ARGS[@]} -output openssl.xcframework
	tar -cJf openssl.xcframework.tar.xz openssl.xcframework
}

function build_libssh2() {
	setup_variables $1

	test -d libssh2-1.9.0 || wget https://github.com/libssh2/libssh2/releases/download/libssh2-1.9.0/libssh2-1.9.0.tar.gz && tar xzf libssh2-1.9.0.tar.gz
	cd libssh2-1.9.0

	rm -rf build && mkdir build && cd build

	CMAKE_ARGS+=(-DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/libssh2-$PLATFORM \
		-DCRYPTO_BACKEND=OpenSSL \
		-DOPENSSL_ROOT_DIR=$REPO_ROOT/install/openssl-$PLATFORM \
		-DBUILD_EXAMPLES=OFF \
		-DBUILD_TESTING=OFF)

	echo ${CMAKE_ARGS[@]}

	case $PLATFORM in
		"iphoneos"|"iphonesimulator")
			cmake ${CMAKE_ARGS[@]} ..;;
		"maccatalyst")
			cmake ${CMAKE_ARGS[@]} -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" ..;;
	esac

	cmake --build . --target install
}

function build_libssh2_xcframework() {
	cd $REPO_ROOT
	PLATFORMS=( "$@" )
	FRAMEWORKS_ARGS=()

	for p in ${PLATFORMS[@]}; do
		build_libssh2 $p
		FRAMEWORKS_ARGS+=("-library" "install/libssh2-$p/lib/libssh2.a" "-headers" "install/libssh2-$p/include")
	done

	cd $REPO_ROOT
	xcodebuild -create-xcframework ${FRAMEWORKS_ARGS[@]} -output libssh2.xcframework
	tar -cJf libssh2.xcframework.tar.xz libssh2.xcframework
}

#build_pcre iphoneos
#build_pcre_xcframework iphoneos iphonesimulator maccatalyst

build_openssl iphoneos
#build_openssl_xcframework iphoneos iphonesimulator maccatalyst

build_libssh2 iphoneos
#build_libssh2_xcframework iphoneos iphonesimulator maccatalyst

build_libgit2 iphoneos
#build_libgit2_xcframework iphoneos iphonesimulator maccatalyst
