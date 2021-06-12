#!/bin/bash
#
# Builds Clang and LLD from source.

export WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LLVM_PROJECT="${WORKSPACE_ROOT}/tools/llvm-project"

: "${LLVM_REPO:=https://github.com/llvm-mirror/llvm.git}"
: "${LLVM_REF:=master}"

: "${CLANG_REPO:=https://github.com/llvm-mirror/clang.git}"
: "${CLANG_REF:=master}"

: "${LLD_REPO:=https://github.com/llvm-mirror/lld.git}"
: "${LLD_REF:=master}"

: "${LIBCXX_REPO:=https://github.com/llvm-mirror/libcxx.git}"
: "${LIBCXX_REF:=master}"

: "${LLVM_INSTALL_PREFIX:=$WORKSPACE_ROOT/build/llvm-install}"

: "${CXX:=clang++}"
: "${CC:=clang}"

if [ ! -d "${LLVM_PROJECT}" ]; then
  mkdir -p "${LLVM_PROJECT}" || exit
fi

cd "${LLVM_PROJECT}" || exit


cd "$WORKSPACE_ROOT" || exit

if [ ! -d build/clang ]; then
  mkdir -p build/clang || exit
fi

# Build clang toolchain
(mkdir -p build/clang && \
 cd build/clang && \
 cmake -GNinja \
       -DCMAKE_CXX_COMPILER="$CXX" \
       -DCMAKE_C_COMPILER="$CC" \
       -DCMAKE_BUILD_TYPE=MinSizeRel \
       -DCMAKE_INSTALL_PREFIX="${LLVM_INSTALL_PREFIX}" \
       -DCMAKE_BUILD_WITH_INSTALL_RPATH="yes" \
       -DLLVM_TARGETS_TO_BUILD=X86 \
       -DLLVM_ENABLE_PROJECTS="lld;clang" \
       "${LLVM_PROJECT}/llvm" && \
  ninja install-clang \
        install-clang-headers \
        install-llvm-ar \
        install-lld) || exit

# Build libcxx using clang we just built
(mkdir -p build/libcxx && \
 cd build/libcxx && \
 cmake -GNinja \
       -DCMAKE_CXX_COMPILER="${LLVM_INSTALL_PREFIX}/bin/clang++" \
       -DCMAKE_C_COMPILER="${LLVM_INSTALL_PREFIX}/bin/clang" \
       -DCMAKE_CXX_FLAGS="-idirafter ${WORKSPACE_ROOT}/build/clang/lib/clang/10.0.0/include/" \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX="${LLVM_INSTALL_PREFIX}" \
       -DLLVM_PATH="${LLVM_PROJECT}/llvm" \
       -DLIBCXX_CXX_ABI=libstdc++ \
       "${LLVM_PROJECT}/libcxx" && \
  ninja install) || exit
