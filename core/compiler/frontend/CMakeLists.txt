# Include Seoggi compilation rules
include(SeoggiCompile)

# Collect frontend source files
file(GLOB FRONTEND_SOURCES
    "*.seo"
)

# Create frontend library
add_seoggi_library(seoggi_frontend
    SOURCES ${FRONTEND_SOURCES}
    INCLUDES
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/../../include
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
        ${LLVM_INCLUDE_DIRS}
        ${Z3_INCLUDE_DIR}
    DEPENDS
        seoggi_compiler
)

target_link_libraries(seoggi_frontend
    PUBLIC
        seoggi_compiler
        ${LLVM_LIBRARIES}
        ${Z3_LIBRARIES}
)
