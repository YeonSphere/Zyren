# Collect quantum source files
file(GLOB_RECURSE QUANTUM_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

# Create quantum library
add_library(seoggi_quantum STATIC ${QUANTUM_SOURCES})

target_link_libraries(seoggi_quantum
    PUBLIC
    seoggi_runtime
    ${LLVM_LIBRARIES}
    ${Boost_LIBRARIES}
)

target_include_directories(seoggi_quantum
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
