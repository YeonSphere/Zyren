# Include Seoggi compilation rules
include(SeoggiCompile)

# Collect source files
file(GLOB_RECURSE NEURAL_SEO_SOURCES
    "*.seo"
)

file(GLOB_RECURSE NEURAL_CPP_SOURCES
    "*.cpp"
    "*.c"
)

# Create neural libraries
add_seoggi_library(seoggi_neural_seo
    SOURCES ${NEURAL_SEO_SOURCES}
    INCLUDES
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
        ${CMAKE_CURRENT_SOURCE_DIR}/../../include
        ${LLVM_INCLUDE_DIRS}
        ${Z3_INCLUDE_DIR}
        ${Boost_INCLUDE_DIRS}
    DEPENDS
        seoggi_runtime
        seoggi_ai
        seoggi_memory
)

add_library(seoggi_neural_cpp STATIC ${NEURAL_CPP_SOURCES})
target_include_directories(seoggi_neural_cpp PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../include
    ${LLVM_INCLUDE_DIRS}
    ${Z3_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
)

# Create main neural library
add_library(seoggi_neural INTERFACE)
target_link_libraries(seoggi_neural
    INTERFACE
        seoggi_neural_seo
        seoggi_neural_cpp
        seoggi_runtime
        seoggi_ai
        seoggi_memory
)

target_include_directories(seoggi_neural
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Install targets
install(TARGETS seoggi_neural seoggi_neural_seo seoggi_neural_cpp
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/neural
    FILES_MATCHING PATTERN "*.h")
