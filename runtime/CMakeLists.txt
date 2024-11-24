# Collect runtime source files
file(GLOB_RECURSE RUNTIME_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

# Create runtime library
add_library(seoggi_runtime STATIC ${RUNTIME_SOURCES})

target_link_libraries(seoggi_runtime
    PUBLIC
    ${LLVM_LIBRARIES}
    ${Boost_LIBRARIES}
    Threads::Threads
)

target_include_directories(seoggi_runtime
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
