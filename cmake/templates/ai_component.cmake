# Include Seoggi compilation rules
include(SeoggiCompile)

# Collect source files
file(GLOB_RECURSE COMPONENT_SEO_SOURCES
    "*.seo"
)

file(GLOB_RECURSE COMPONENT_CPP_SOURCES
    "*.cpp"
    "*.c"
)

# Create component libraries
add_seoggi_library(seoggi_${COMPONENT_NAME}_seo
    SOURCES ${COMPONENT_SEO_SOURCES}
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
)

add_library(seoggi_${COMPONENT_NAME}_cpp STATIC ${COMPONENT_CPP_SOURCES})
target_include_directories(seoggi_${COMPONENT_NAME}_cpp PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../include
    ${LLVM_INCLUDE_DIRS}
    ${Z3_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
)

# Create main component library
add_library(seoggi_${COMPONENT_NAME} INTERFACE)
target_link_libraries(seoggi_${COMPONENT_NAME}
    INTERFACE
        seoggi_${COMPONENT_NAME}_seo
        seoggi_${COMPONENT_NAME}_cpp
        seoggi_runtime
        seoggi_ai
)

target_include_directories(seoggi_${COMPONENT_NAME}
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Install targets
install(TARGETS seoggi_${COMPONENT_NAME} seoggi_${COMPONENT_NAME}_seo seoggi_${COMPONENT_NAME}_cpp
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/ai/${COMPONENT_NAME}
    FILES_MATCHING PATTERN "*.h")
