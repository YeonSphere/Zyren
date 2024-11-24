# Collect backend source files
file(GLOB BACKEND_CPP_SOURCES
    "*.cpp"
    "*.c"
)

# Create backend library
add_library(seoggi_backend STATIC ${BACKEND_CPP_SOURCES})

target_include_directories(seoggi_backend PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../include
    ${LLVM_INCLUDE_DIRS}
    ${Z3_INCLUDE_DIR}
)

target_link_libraries(seoggi_backend
    PUBLIC
        seoggi_compiler
        ${LLVM_LIBRARIES}
        ${Z3_LIBRARIES}
)

# Install targets
install(TARGETS seoggi_backend
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/
    DESTINATION include/seoggi/compiler/backend
    FILES_MATCHING PATTERN "*.h*")
