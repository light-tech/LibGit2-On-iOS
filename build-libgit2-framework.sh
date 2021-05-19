export REPO_ROOT=`pwd`
export PATH=$PATH:$REPO_ROOT/tools/bin
git clone --recursive https://github.com/libgit2/libgit2.git
cd libgit2
# git submodule update --recursive
mkdir build && cd build
cmake ..
cmake --build .
