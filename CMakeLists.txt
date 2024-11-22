cmake_minimum_required(VERSION 3.10)
project(Seoggi VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find LLVM
find_package(LLVM REQUIRED CONFIG)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

# Find Z3
find_package(Z3 REQUIRED CONFIG)
include_directories(${Z3_INCLUDE_DIRS})

# Find LibEdit (optional)
find_library(LIBEDIT_LIBRARY NAMES edit libedit)
find_path(LIBEDIT_INCLUDE_DIR NAMES histedit.h)
if(LIBEDIT_LIBRARY AND LIBEDIT_INCLUDE_DIR)
    set(LibEdit_FOUND TRUE)
    set(LibEdit_INCLUDE_DIRS ${LIBEDIT_INCLUDE_DIR})
    set(LibEdit_LIBRARIES ${LIBEDIT_LIBRARY})
    message(STATUS "Found LibEdit: ${LIBEDIT_LIBRARY}")
else()
    message(STATUS "LibEdit not found - some features will be disabled")
endif()

# Add source directories
add_subdirectory(core)
