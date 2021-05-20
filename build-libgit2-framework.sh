export REPO_ROOT=`pwd`
export PATH=$PATH:$REPO_ROOT/tools/bin
git clone --recursive https://github.com/libgit2/libgit2.git
cd libgit2
# git submodule update --recursive
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$REPO_ROOT/install \
      -DBUILD_SHARED_LIBS=NO \
      -DBUILD_CLAR=NO \
      -DCMAKE_C_FLAGS="-target x86_64-apple-ios14.1-macabi" \
      -DCMAKE_CXX_FLAGS="-target x86_64-apple-ios14.1-macabi" \
      ..

cmake -L

cmake --build . --target install
