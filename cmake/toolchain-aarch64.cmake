set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# RK3326 Cortex-A35 optimization flags
set(CMAKE_C_FLAGS_INIT "-mcpu=cortex-a35 -fPIC")
set(CMAKE_CXX_FLAGS_INIT "-mcpu=cortex-a35 -fPIC")
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG -mcpu=cortex-a35 -fomit-frame-pointer")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -mcpu=cortex-a35 -fomit-frame-pointer")

# Multiarch configuration
set(CMAKE_LIBRARY_ARCHITECTURE aarch64-linux-gnu)
set(PKG_CONFIG_EXECUTABLE /usr/bin/aarch64-linux-gnu-pkg-config)
set(ENV{PKG_CONFIG} /usr/bin/aarch64-linux-gnu-pkg-config)
set(ENV{PKG_CONFIG_PATH} "/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig")

set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu /usr/include/aarch64-linux-gnu /usr)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)
