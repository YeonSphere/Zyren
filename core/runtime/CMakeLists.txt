# Quantum runtime library
add_library(quantum_runtime SHARED
    quantum_runtime.cpp
    state_manager.cpp
    gate_executor.cpp
    error_corrector.cpp
    decoherence_monitor.cpp
    entanglement_tracker.cpp
    quantum_optimizer.cpp
)

target_include_directories(quantum_runtime
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(quantum_runtime
    PUBLIC
    seoggi_common
)

# Neural runtime library
add_library(neural_runtime SHARED
    neural_runtime.cpp
    model_manager.cpp
    training_engine.cpp
    inference_engine.cpp
    optimization_engine.cpp
)

target_include_directories(neural_runtime
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(neural_runtime
    PUBLIC
    seoggi_common
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
