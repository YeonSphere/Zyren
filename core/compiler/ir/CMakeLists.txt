# Include Seoggi compilation rules
include(SeoggiCompile)

# Collect IR source files
file(GLOB IR_SOURCES
    "*.seo"
)

# Create IR library
add_seoggi_library(seoggi_ir
    SOURCES ${IR_SOURCES}
    INCLUDES
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/../../include
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
        ${LLVM_INCLUDE_DIRS}
        ${Z3_INCLUDE_DIR}
    DEPENDS
        seoggi_compiler
)

target_link_libraries(seoggi_ir
    PUBLIC
        seoggi_compiler
        ${LLVM_LIBRARIES}
        ${Z3_LIBRARIES}
)
