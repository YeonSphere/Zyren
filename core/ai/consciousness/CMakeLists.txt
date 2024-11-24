file(GLOB_RECURSE CONSCIOUSNESS_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_consciousness STATIC ${CONSCIOUSNESS_SOURCES})

target_link_libraries(seoggi_consciousness
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_cognition
)

target_include_directories(seoggi_consciousness
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_consciousness
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/consciousness
    FILES_MATCHING PATTERN "*.h")
