# Collect all .seo files
file(GLOB_RECURSE SEO_SOURCES
    "*.seo"
)

# Collect all C++ files
file(GLOB_RECURSE CPP_SOURCES
    "*.cpp"
    "*.c"
)

# Create core libraries
add_seoggi_library(seoggi_core_seo
    SOURCES ${SEO_SOURCES}
    INCLUDES 
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/compiler/include
        ${CMAKE_CURRENT_SOURCE_DIR}/runtime/include
        ${CMAKE_CURRENT_SOURCE_DIR}/ai/include
    DEPENDS
        seoggi_compiler
)

add_library(seoggi_core_cpp STATIC ${CPP_SOURCES})
target_include_directories(seoggi_core_cpp PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/compiler/include
    ${CMAKE_CURRENT_SOURCE_DIR}/runtime/include
    ${CMAKE_CURRENT_SOURCE_DIR}/ai/include
    ${LLVM_INCLUDE_DIRS}
    ${Z3_INCLUDE_DIR}
    ${LIBEDIT_INCLUDE_DIRS}
    ${ZLIB_INCLUDE_DIRS}
    ${LIBXML2_INCLUDE_DIR}
    ${CURL_INCLUDE_DIRS}
    ${OPENSSL_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
)

# Create main core library that combines both
add_library(seoggi_core INTERFACE)
target_link_libraries(seoggi_core
    INTERFACE
        seoggi_core_seo
        seoggi_core_cpp
        ${LLVM_LIBRARIES}
        ${Z3_LIBRARIES}
        ${LIBEDIT_LIBRARIES}
        ${ZLIB_LIBRARIES}
        ${LIBXML2_LIBRARIES}
        ${CURL_LIBRARIES}
        ${OPENSSL_LIBRARIES}
        ${Boost_LIBRARIES}
        Threads::Threads
)

# Add subdirectories
add_subdirectory(ai)
add_subdirectory(compiler)
add_subdirectory(runtime)

# Export include directories
target_include_directories(seoggi_core
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/compiler/include
        ${CMAKE_CURRENT_SOURCE_DIR}/runtime/include
        ${CMAKE_CURRENT_SOURCE_DIR}/ai/include
)
