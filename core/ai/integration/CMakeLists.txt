file(GLOB_RECURSE INTEGRATION_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_integration STATIC ${INTEGRATION_SOURCES})

target_link_libraries(seoggi_integration
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_consciousness
    seoggi_cognition
)

target_include_directories(seoggi_integration
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_integration
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/integration
    FILES_MATCHING PATTERN "*.h")
