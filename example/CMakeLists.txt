cmake_minimum_required(VERSION 2.9)
project(test)

set(CMAKE_CXX_COMPILER "/home/ubuntu/cppcoro/build/llvm-install/bin/clang++")
set(CMAKE_CXX_FLAGS "-idirafter /home/ubuntu/cppcoro/build/clang/lib/clang/10.0.0/include -g -fcoroutines-ts -stdlib=libc++ -std=c++17 -Wall")
add_executable(test main.cpp)

target_include_directories(test PRIVATE "/home/ubuntu/cppcoro/include")
target_link_directories(test PRIVATE "/home/ubuntu/cppcoro/build/llvm-install/lib" "/home/ubuntu/cppcoro/build/cppcoro_build/lib")
target_link_libraries(test LINK_PUBLIC cppcoro)
