file(GLOB_RECURSE LANGUAGE_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_language STATIC ${LANGUAGE_SOURCES})

target_link_libraries(seoggi_language
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_interaction
)

target_include_directories(seoggi_language
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_language
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/language
    FILES_MATCHING PATTERN "*.h")
