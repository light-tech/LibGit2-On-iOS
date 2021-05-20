export REPO_ROOT=`pwd`
export PATH=$PATH:$REPO_ROOT/tools/bin

### Setup common environment variables to run CMake for a given platform
### Usage:      setup_variables PLATFORM
### where PLATFORM is the platform to build for and should be one of
###    iphoneos
###    iphonesimulator
###    maccatalyst
### (macos and M1 macos to be added in the future)
###
### After this function is executed, the variable $PLATFORM and $CMAKE_ARGS
### providing basic/common CMake options will be set.
###
function setup_variables() {
	PLATFORM=$1

	CMAKE_ARGS=(-DBUILD_SHARED_LIBS=NO -DCMAKE_BUILD_TYPE=Release)

	case $PLATFORM in
		"iphoneos")
			SYSROOT=`xcodebuild -version -sdk iphoneos Path`
			CMAKE_ARGS+=("-DCMAKE_OSX_SYSROOT=$SYSROOT");;
		"iphonesimulator")
			SYSROOT=`xcodebuild -version -sdk iphonesimulator Path`
			CMAKE_ARGS+=("-DCMAKE_OSX_SYSROOT=$SYSROOT");;
		"maccatalyst")
			# No need to set up SYSROOT as CMake should find MacOS SDK automatically
			echo "Set up variables for Mac Catalyst";;
		*)
			echo "Unsupported or missing platform!"
			echo "Usage: setup_variables [iphoneos|iphonesimulator|maccatalyst]";;
	esac
}

### Build libgit2 for a single platform (given as the first and only argument)
### See @setup_variables for the list of available platform names
###
function build_libgit2() {
	setup_variables $1

	git clone --recursive https://github.com/libgit2/libgit2.git
	cd libgit2
	# git submodule update --recursive

	mkdir build && cd build
	CMAKE_ARGS+=(-DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/libgit2-$PLATFORM
		-DBUILD_CLAR=NO)

	case $PLATFORM in
		"iphoneos"|"iphonesimulator")
			cmake ${CMAKE_ARGS[@]} ..;;
		"maccatalyst")
			cmake ${CMAKE_ARGS[@]} -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" ..;;
	esac

	#cd ..
	#cmake -L
	#cd build

	cmake --build . --target install
}

function build_libgit2_xcframework() {
	cd $REPO_ROOT
	FRAMEWORKS_ARGS=()
	FRAMEWORKS_ARGS+=("-library" "install/libgit2/lib/libgit2.a" "-headers" "install/libgit2/include")
	xcodebuild -create-xcframework ${FRAMEWORKS_ARGS[@]} -output Clibgit2.xcframework
	tar -cJf Clibgit2.xcframework.tar.xz Clibgit2.xcframework
}

### Build libpcre for a single platform
### See @setup_variables for the list of available platform names
###
function build_pcre() {
	setup_variables $1

	wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz # https://ftp.pcre.org/pub/pcre/pcre2-10.36.tar.gz
	tar xzf pcre-8.44.tar.gz
	cd pcre-8.44

	mkdir build && cd build
	CMAKE_ARGS+=(-DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/pcre-$PLATFORM \
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

	cd ..
	cmake -L
	cd build

	cmake --build . --target install
}

function build_pcre_framework() {
	cd $REPO_ROOT
	FRAMEWORKS_ARGS=()
	FRAMEWORKS_ARGS+=("-library" "install/pcre/lib/libpcre.a" "-headers" "install/pcre/include")
	xcodebuild -create-xcframework ${FRAMEWORKS_ARGS[@]} -output LibPCRE.xcframework
	tar -cJf LibPCRE.xcframework.tar.xz LibPCRE.xcframework
}

build_libgit2 maccatalyst
build_pcre maccatalyst