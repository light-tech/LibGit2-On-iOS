export REPO_ROOT=`pwd`
export PATH=$PATH:$REPO_ROOT/tools/bin
AVAILABLE_PLATFORMS=(iphoneos iphonesimulator maccatalyst)
AVAILABLE_FRAMEWORKS=(libpcre openssl libssh2 libgit2)

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
function setup_variables() {
	cd $REPO_ROOT
	PLATFORM=$1

	CMAKE_ARGS=(-DBUILD_SHARED_LIBS=NO \
		-DCMAKE_BUILD_TYPE=Release)

	case $PLATFORM in
		"iphoneos")
			SYSROOT=`xcodebuild -version -sdk iphoneos Path`
			CMAKE_ARGS+=(-DCMAKE_C_COMPILER_WORKS=ON \
				-DCMAKE_CXX_COMPILER_WORKS=ON \
				-DCMAKE_OSX_ARCHITECTURES=arm64 \
				-DCMAKE_OSX_SYSROOT=$SYSROOT);;

		"iphonesimulator")
			SYSROOT=`xcodebuild -version -sdk iphonesimulator Path`
			CMAKE_ARGS+=(-DCMAKE_OSX_SYSROOT=$SYSROOT);;

		"maccatalyst")
			SYSROOT=`xcodebuild -version -sdk macosx Path`;;

		*)
			echo "Unsupported or missing platform! Must be one of" ${AVAILABLE_PLATFORMS[@]};;
	esac
}

### Build libgit2 for a single platform (given as the first and only argument)
### See @setup_variables for the list of available platform names
### Assume openssl and libssh2 was built
function build_libgit2() {
	setup_variables $1

	# test -d libgit2 || git clone --recursive https://github.com/libgit2/libgit2.git
	# cd libgit2
	# git submodule update --recursive

	rm -rf libgit2-1.1.0
	test -f libgit2-1.1.0.tar.gz || wget https://github.com/libgit2/libgit2/releases/download/v1.1.0/libgit2-1.1.0.tar.gz
	tar xzf libgit2-1.1.0.tar.gz
	cd libgit2-1.1.0

	rm -rf build && mkdir build && cd build

	CMAKE_ARGS+=(-DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/$PLATFORM \
		-DBUILD_CLAR=NO)

	# See libgit2/cmake/FindPkgLibraries.cmake to understand how libgit2 looks for libssh2
	# Basically, setting LIBSSH2_FOUND forces SSH support and since we are building static library,
	# we only need the headers.
	CMAKE_ARGS+=(-DOPENSSL_ROOT_DIR=$REPO_ROOT/install/$PLATFORM \
		-DUSE_SSH=ON \
		-DLIBSSH2_FOUND=YES \
		-DLIBSSH2_INCLUDE_DIRS=$REPO_ROOT/install/$PLATFORM/include)

	case $PLATFORM in
		"iphoneos"|"iphonesimulator")
			cmake ${CMAKE_ARGS[@]} ..;;

		"maccatalyst")
			cmake ${CMAKE_ARGS[@]} -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" ..;;
	esac

	cmake --build . --target install
}

### Build libpcre for a given platform
function build_libpcre() {
	setup_variables $1

	rm -rf pcre-8.44
	test -f pcre-8.44.tar.gz || wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz # https://ftp.pcre.org/pub/pcre/pcre2-10.36.tar.gz
	tar xzf pcre-8.44.tar.gz
	cd pcre-8.44

	rm -rf build && mkdir build && cd build
	CMAKE_ARGS+=(-DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/$PLATFORM \
		-DPCRE_BUILD_PCRECPP=NO \
		-DPCRE_BUILD_PCREGREP=NO \
		-DPCRE_BUILD_TESTS=NO \
		-DPCRE_SUPPORT_LIBBZ2=NO)

	case $PLATFORM in
		"iphoneos"|"iphonesimulator")
			cmake ${CMAKE_ARGS[@]} ..;;

		"maccatalyst")
			cmake ${CMAKE_ARGS[@]} -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" ..;;
	esac

	cmake --build . --target install >/dev/null
}

### Build openssl for a given platform
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
	./Configure --prefix=$REPO_ROOT/install/$PLATFORM \
		--openssldir=$REPO_ROOT/install/$PLATFORM \
		$TARGET_OS no-shared no-dso no-hw no-engine

	make >/dev/null
	make install_sw install_ssldirs >/dev/null

	# Merge two static libraries libssl.a and libcrypto.a into a single static library openssl.a
	# since xcodebuild/XCFramework does not allow multiple static library specification
	# cd $REPO_ROOT/install/$PLATFORM/lib
	# libtool -static -o openssl.a *.a
}

### Build libssh2 for a given platform (assume openssl was built)
function build_libssh2() {
	setup_variables $1

	rm -rf libssh2-1.9.0
	test -f libssh2-1.9.0.tar.gz || wget https://github.com/libssh2/libssh2/releases/download/libssh2-1.9.0/libssh2-1.9.0.tar.gz
	tar xzf libssh2-1.9.0.tar.gz
	cd libssh2-1.9.0

	rm -rf build && mkdir build && cd build

	CMAKE_ARGS+=(-DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/$PLATFORM \
		-DCRYPTO_BACKEND=OpenSSL \
		-DOPENSSL_ROOT_DIR=$REPO_ROOT/install/$PLATFORM \
		-DBUILD_EXAMPLES=OFF \
		-DBUILD_TESTING=OFF)

	case $PLATFORM in
		"iphoneos"|"iphonesimulator")
			cmake ${CMAKE_ARGS[@]} ..;;

		"maccatalyst")
			cmake ${CMAKE_ARGS[@]} -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" ..;;
	esac

	cmake --build . --target install >/dev/null
}

### Copy SwiftGit2's module.modulemap to libgit2.xcframework/*/Headers
### so that we can use libgit2.xcframework with SwiftGit2
function copy_modulemap() {
	local FWDIRS=$(find libgit2.xcframework -mindepth 1 -maxdepth 1 -type d)
	for d in ${FWDIRS[@]}; do
		echo $d
		cp module.modulemap $d/Headers/
	done
}

### Create xcframework for a given library
function build_xcframework() {
	local FWNAME=$1
	shift
	local PLATFORMS=( "$@" )
	local FRAMEWORKS_ARGS=()

	echo "Building" $FWNAME "XCFramework containing" ${PLATFORMS[@]}

	for p in ${PLATFORMS[@]}; do
		FRAMEWORKS_ARGS+=("-library" "install/$p/$FWNAME.a" "-headers" "install/$p/include")
	done

	cd $REPO_ROOT
	xcodebuild -create-xcframework ${FRAMEWORKS_ARGS[@]} -output $FWNAME.xcframework
}

### Build all frameworks for every available platforms

for p in ${AVAILABLE_PLATFORMS[@]}; do
	build_libpcre $p
	build_openssl $p
	build_libssh2 $p
	build_libgit2 $p

	# Merge all static libs as libgit2.a
	cd $REPO_ROOT/install/$p
	libtool -static -o libgit2.a lib/*.a
done

#for fw in ${AVAILABLE_FRAMEWORKS[@]}; do
#	build_xcframework $fw ${AVAILABLE_PLATFORMS[@]}
#done

build_xcframework libgit2 ${AVAILABLE_PLATFORMS[@]}
copy_modulemap
