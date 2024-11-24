file(GLOB_RECURSE MEMORY_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_memory STATIC ${MEMORY_SOURCES})

target_link_libraries(seoggi_memory
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_language
)

target_include_directories(seoggi_memory
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_memory
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/memory
    FILES_MATCHING PATTERN "*.h")
