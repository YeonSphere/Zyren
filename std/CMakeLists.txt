# Collect standard library source files
file(GLOB_RECURSE STD_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
    neural.seo
)

# Create standard library
add_library(seoggi_std STATIC ${STD_SOURCES})

target_link_libraries(seoggi_std
    PUBLIC
    seoggi_runtime
    seoggi_quantum
    ${LLVM_LIBRARIES}
    ${Boost_LIBRARIES}
)

target_include_directories(seoggi_std
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
