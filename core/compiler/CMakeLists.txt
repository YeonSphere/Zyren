# Include Seoggi compilation rules
include(SeoggiCompile)

# Collect compiler source files
file(GLOB_RECURSE COMPILER_SEO_SOURCES
    "ast.seo"
    "lexer.seo"
    "parser.seo"
    "type.seo"
    "type_checker.seo"
    "analyzer.seo"
    "codegen.seo"
    "driver.seo"
    "error.seo"
    "scope.seo"
    "symbol_table.seo"
    "smt.seo"
    "optimizer.seo"
    "ai_features.seo"
)

file(GLOB_RECURSE COMPILER_CPP_SOURCES
    "*.cpp"
    "*.c"
)

# Create compiler libraries
add_seoggi_library(seoggi_compiler_seo
    SOURCES ${COMPILER_SEO_SOURCES}
    INCLUDES
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
        ${LLVM_INCLUDE_DIRS}
        ${Z3_INCLUDE_DIR}
    DEPENDS
        seoggi_core
)

add_library(seoggi_compiler_cpp STATIC ${COMPILER_CPP_SOURCES})
target_include_directories(seoggi_compiler_cpp PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
    ${LLVM_INCLUDE_DIRS}
    ${Z3_INCLUDE_DIR}
)

# Create main compiler library
add_library(seoggi_compiler INTERFACE)
target_link_libraries(seoggi_compiler
    INTERFACE
        seoggi_compiler_seo
        seoggi_compiler_cpp
        ${LLVM_LIBRARIES}
        ${Z3_LIBRARIES}
)

# Export include directories
target_include_directories(seoggi_compiler
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Add subdirectories for specific components
add_subdirectory(passes)
add_subdirectory(ir)
add_subdirectory(frontend)
add_subdirectory(backend)
add_subdirectory(analysis)

# Create bootstrap compiler
add_executable(seoggi_compiler_bootstrap seoggi_compiler)
target_link_libraries(seoggi_compiler_bootstrap
    PRIVATE
        seoggi_compiler
        ${LLVM_LIBRARIES}
        ${Z3_LIBRARIES}
)

if(LibEdit_FOUND)
    target_link_libraries(seoggi_compiler_bootstrap PRIVATE ${LibEdit_LIBRARIES})
endif()

install(TARGETS seoggi_compiler_bootstrap
    RUNTIME DESTINATION bin
)
