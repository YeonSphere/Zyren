file(GLOB_RECURSE QUANTUM_SOURCES
    "*.seo"
    "*.cpp"
    "*.c"
)

add_library(seoggi_ai_quantum STATIC ${QUANTUM_SOURCES})

target_link_libraries(seoggi_ai_quantum
    PUBLIC
    seoggi_runtime
    seoggi_ai
    seoggi_neural
)

target_include_directories(seoggi_ai_quantum
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS seoggi_ai_quantum
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/quantum
    FILES_MATCHING PATTERN "*.h")
