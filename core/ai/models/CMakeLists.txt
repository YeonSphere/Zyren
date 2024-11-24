file(GLOB_RECURSE MODELS_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_ai_models STATIC ${MODELS_SOURCES})

target_link_libraries(seoggi_ai_models
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_ai_safety
)

target_include_directories(seoggi_ai_models
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_ai_models
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/models
    FILES_MATCHING PATTERN "*.h")
