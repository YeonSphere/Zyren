file(GLOB_RECURSE INTERACTION_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_interaction STATIC ${INTERACTION_SOURCES})

target_link_libraries(seoggi_interaction
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_integration
)

target_include_directories(seoggi_interaction
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_interaction
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/interaction
    FILES_MATCHING PATTERN "*.h")
