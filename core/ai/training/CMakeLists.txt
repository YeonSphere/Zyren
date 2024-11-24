file(GLOB_RECURSE TRAINING_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_ai_training STATIC ${TRAINING_SOURCES})

target_link_libraries(seoggi_ai_training
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_ai_models
)

target_include_directories(seoggi_ai_training
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_ai_training
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/training
    FILES_MATCHING PATTERN "*.h")
