file(GLOB_RECURSE COGNITION_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_cognition STATIC ${COGNITION_SOURCES})

target_link_libraries(seoggi_cognition
    PUBLIC
    seoggi_runtime
    seoggi_ai
)

target_include_directories(seoggi_cognition
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_cognition
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/cognition
    FILES_MATCHING PATTERN "*.h")
