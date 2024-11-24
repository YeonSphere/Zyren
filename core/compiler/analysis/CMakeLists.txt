# Include Seoggi compilation rules
include(SeoggiCompile)

# Collect analysis source files
file(GLOB ANALYSIS_SOURCES
    "*.seo"
)

# Create analysis library
add_seoggi_library(seoggi_analysis
    SOURCES ${ANALYSIS_SOURCES}
    INCLUDES
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/../../include
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
        ${LLVM_INCLUDE_DIRS}
        ${Z3_INCLUDE_DIR}
    DEPENDS
        seoggi_compiler
)

target_link_libraries(seoggi_analysis
    PUBLIC
        seoggi_compiler
        ${LLVM_LIBRARIES}
        ${Z3_LIBRARIES}
)
