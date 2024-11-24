add_executable(seoggi_bootstrap
    src/main.cpp
    src/lexer.cpp
    src/parser.cpp
    src/codegen.cpp
)

target_include_directories(seoggi_bootstrap
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(seoggi_bootstrap
    PRIVATE
    ${LLVM_LIBRARIES}
)
