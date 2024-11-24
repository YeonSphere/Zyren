cmake_minimum_required(VERSION 3.15)
project(Seoggi VERSION 0.1.0 LANGUAGES C CXX)

# Add cmake modules path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Set CMake policies
cmake_policy(SET CMP0167 NEW)

# Include Seoggi compilation rules
include(SeoggiCompile)

# Set build type if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Find required packages
find_package(LLVM REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Boost REQUIRED COMPONENTS system filesystem)
find_package(LibEdit REQUIRED)
find_package(Z3 REQUIRED)
find_package(ZLIB REQUIRED)
find_package(LibXml2 REQUIRED)
find_package(CURL REQUIRED)
find_package(Threads REQUIRED)

# Add subdirectories
add_subdirectory(core)
add_subdirectory(std)

# Install configuration
install(
    TARGETS seoggi_runtime seoggi_compiler
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)
