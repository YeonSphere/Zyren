file(GLOB_RECURSE PERSONALITY_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_personality STATIC ${PERSONALITY_SOURCES})

target_link_libraries(seoggi_personality
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_neural
)

target_include_directories(seoggi_personality
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_personality
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/personality
    FILES_MATCHING PATTERN "*.h")
