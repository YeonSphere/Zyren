file(GLOB_RECURSE SAFETY_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_ai_safety STATIC ${SAFETY_SOURCES})

target_link_libraries(seoggi_ai_safety
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_ai_quantum
    seoggi_personality
)

target_include_directories(seoggi_ai_safety
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_ai_safety
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/safety
    FILES_MATCHING PATTERN "*.h")
