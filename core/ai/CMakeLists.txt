# AI module components
add_library(seoggi_ai SHARED
    training_manager.cpp
    model_framework.cpp
    safety/bounds_enforcer.cpp
    safety/development_monitor.cpp
    safety/validation_engine.cpp
    neural/network.cpp
    neural/layers.cpp
    neural/optimizer.cpp
    neural/loss.cpp
    quantum/circuit.cpp
    quantum/gates.cpp
    quantum/simulator.cpp
)

target_include_directories(seoggi_ai
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/safety/include
    ${CMAKE_CURRENT_SOURCE_DIR}/neural/include
    ${CMAKE_CURRENT_SOURCE_DIR}/quantum/include
)

target_link_libraries(seoggi_ai
    PUBLIC
    seoggi_common
)

# AI safety module
add_library(seoggi_ai_safety SHARED
    safety/model_framework.cpp
    safety/architecture_builder.cpp
    safety/component_factory.cpp
    safety/validator_factory.cpp
    safety/model_analyzer.cpp
    safety/performance_profiler.cpp
    safety/bounds_checker.cpp
    safety/state_validator.cpp
)

target_include_directories(seoggi_ai_safety
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/safety/include
)

target_link_libraries(seoggi_ai_safety
    PUBLIC
    seoggi_common
    seoggi_ai
)

# Install targets
install(TARGETS seoggi_ai seoggi_ai_safety
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/ safety/include/ neural/include/ quantum/include/
    DESTINATION include/seoggi/ai
    FILES_MATCHING PATTERN "*.h")
