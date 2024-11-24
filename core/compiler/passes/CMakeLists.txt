# Include Seoggi compilation rules
include(SeoggiCompile)

# Collect pass source files
file(GLOB PASS_SOURCES
    "*.seo"
)

# Create passes library
add_seoggi_library(seoggi_passes
    SOURCES ${PASS_SOURCES}
    INCLUDES
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/../../include
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
        ${LLVM_INCLUDE_DIRS}
        ${Z3_INCLUDE_DIR}
    DEPENDS
        seoggi_compiler
)

target_link_libraries(seoggi_passes
    PUBLIC
        seoggi_compiler
        ${LLVM_LIBRARIES}
        ${Z3_LIBRARIES}
)

# Export include directories
target_include_directories(seoggi_passes
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)
