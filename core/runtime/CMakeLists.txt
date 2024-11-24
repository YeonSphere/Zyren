cmake_minimum_required(VERSION 3.15)

# Set Seoggi file extension
set_source_files_properties(*.seo PROPERTIES LANGUAGE Seoggi)

# Enable Seoggi language support
enable_language(Seoggi)

# Quantum runtime library
add_seoggi_library(quantum_runtime
    SOURCES
        quantum_runtime.seo
        state_manager.seo
    INCLUDES
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/include
    DEPENDS
        seoggi_compiler
)

set_target_properties(quantum_runtime PROPERTIES
    LINKER_LANGUAGE Seoggi
    Seoggi_STANDARD 23
)

target_link_libraries(quantum_runtime
    PUBLIC
    seoggi_compiler
    seoggi_backend
)

# Neural runtime library
add_seoggi_library(neural_runtime
    SOURCES
        neural_runtime.seo
        model_manager.seo
        training_engine.seo
    INCLUDES
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/include
    DEPENDS
        quantum_runtime
)

set_target_properties(neural_runtime PROPERTIES
    LINKER_LANGUAGE Seoggi
    Seoggi_STANDARD 23
)

target_link_libraries(neural_runtime
    PUBLIC
    quantum_runtime
    seoggi_compiler
    seoggi_backend
)

# Install targets
install(TARGETS quantum_runtime neural_runtime
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/runtime
    FILES_MATCHING PATTERN "*.h")
