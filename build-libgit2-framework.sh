export REPO_ROOT=`pwd`
export PATH=$PATH:$REPO_ROOT/tools/bin

function build_libgit2() {
git clone --recursive https://github.com/libgit2/libgit2.git
cd libgit2
# git submodule update --recursive
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/libgit2 \
      -DBUILD_SHARED_LIBS=NO \
      -DBUILD_CLAR=NO \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" \
      ..

#cd ..
#cmake -L
#cd build

cmake --build . --target install

cd $REPO_ROOT
FRAMEWORKS_ARGS=()
FRAMEWORKS_ARGS+=("-library" "install/libgit2/lib/libgit2.a" "-headers" "install/libgit2/include")
xcodebuild -create-xcframework ${FRAMEWORKS_ARGS[@]} -output Clibgit2.xcframework
tar -cJf Clibgit2.xcframework.tar.xz Clibgit2.xcframework
}

function build_pcre() {
wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz # https://ftp.pcre.org/pub/pcre/pcre2-10.36.tar.gz
tar xzf pcre-8.44.tar.gz
cd pcre-8.44

mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install/pcre \
      -DBUILD_SHARED_LIBS=NO \
      -DPCRE_BUILD_PCRECPP=NO \
      -DPCRE_BUILD_PCREGREP=NO \
      -DPCRE_BUILD_TESTS=NO \
      -DPCRE_SUPPORT_LIBBZ2=NO \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" \
      ..

cd ..
cmake -L
cd build

cmake --build . --target install

cd $REPO_ROOT
FRAMEWORKS_ARGS=()
FRAMEWORKS_ARGS+=("-library" "install/pcre/lib/libpcre.a" "-headers" "install/pcre/include")
xcodebuild -create-xcframework ${FRAMEWORKS_ARGS[@]} -output LibPCRE.xcframework
tar -cJf LibPCRE.xcframework.tar.xz LibPCRE.xcframework
}

build_pcre maccatalyst