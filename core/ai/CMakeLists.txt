# Include Seoggi compilation rules
include(SeoggiCompile)

# Set up AI component template
set(AI_COMPONENT_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/templates/ai_component.cmake")

# Function to add AI component
function(add_ai_component component_name)
    set(COMPONENT_NAME ${component_name})
    include(${AI_COMPONENT_TEMPLATE})
endfunction()

# Collect all AI source files
file(GLOB_RECURSE AI_SEO_SOURCES
    "*.seo"
)

file(GLOB_RECURSE AI_CPP_SOURCES
    "*.cpp"
    "*.c"
)

# Create AI libraries
add_seoggi_library(seoggi_ai_seo
    SOURCES ${AI_SEO_SOURCES}
    INCLUDES
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/models/include
        ${CMAKE_CURRENT_SOURCE_DIR}/neural/include
        ${CMAKE_CURRENT_SOURCE_DIR}/quantum/include
        ${CMAKE_CURRENT_SOURCE_DIR}/training/include
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
        ${LLVM_INCLUDE_DIRS}
        ${Z3_INCLUDE_DIR}
        ${Boost_INCLUDE_DIRS}
    DEPENDS
        seoggi_runtime
)

add_library(seoggi_ai_cpp STATIC ${AI_CPP_SOURCES})
target_include_directories(seoggi_ai_cpp PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/models/include
    ${CMAKE_CURRENT_SOURCE_DIR}/neural/include
    ${CMAKE_CURRENT_SOURCE_DIR}/quantum/include
    ${CMAKE_CURRENT_SOURCE_DIR}/training/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
    ${LLVM_INCLUDE_DIRS}
    ${Z3_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
)

# Create main AI library
add_library(seoggi_ai INTERFACE)
target_link_libraries(seoggi_ai
    INTERFACE
        seoggi_ai_seo
        seoggi_ai_cpp
        seoggi_runtime
        ${LLVM_LIBRARIES}
        ${Boost_LIBRARIES}
        ${Z3_LIBRARIES}
)

# Add subdirectories for AI components
add_ai_component(cognition)
add_ai_component(consciousness)
add_ai_component(integration)
add_ai_component(interaction)
add_ai_component(language)
add_ai_component(memory)
add_ai_component(neural)
add_ai_component(personality)
add_ai_component(quantum)
add_ai_component(safety)
add_ai_component(models)
add_ai_component(training)

target_include_directories(seoggi_ai
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/models/include
        ${CMAKE_CURRENT_SOURCE_DIR}/neural/include
        ${CMAKE_CURRENT_SOURCE_DIR}/quantum/include
        ${CMAKE_CURRENT_SOURCE_DIR}/training/include
)

# Install targets
install(TARGETS seoggi_ai seoggi_ai_seo seoggi_ai_cpp
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/ models/include/ neural/include/ quantum/include/ training/include/
    DESTINATION include/seoggi/ai
    FILES_MATCHING PATTERN "*.h")
