cmake_minimum_required(VERSION 3.20)
project(Seoggi VERSION 0.1.0 LANGUAGES C CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Werror -fPIC)
    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        add_compile_options(-O3 -march=native)
    endif()
endif()

# Find required packages
find_package(LLVM 18.1.8 REQUIRED CONFIG)
find_package(Z3 REQUIRED)
find_package(LibEdit REQUIRED)
find_package(GTest REQUIRED)
find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)
find_package(LibXml2 REQUIRED)
find_package(CURL REQUIRED)

# Custom command to process .seo files into .cpp
function(add_seo_library target)
    set(seo_sources ${ARGN})
    set(cpp_sources)
    foreach(seo_file ${seo_sources})
        get_filename_component(file_name ${seo_file} NAME_WE)
        get_filename_component(file_dir ${seo_file} DIRECTORY)
        set(cpp_file "${CMAKE_CURRENT_BINARY_DIR}/${file_dir}/${file_name}.cpp")
        file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${file_dir}")
        add_custom_command(
            OUTPUT ${cpp_file}
            COMMAND ${CMAKE_BINARY_DIR}/bin/seoggi_compiler ${seo_file} -o ${cpp_file}
            DEPENDS ${seo_file} seoggi_compiler
            COMMENT "Compiling ${seo_file} to C++"
            VERBATIM
        )
        list(APPEND cpp_sources ${cpp_file})
    endforeach()
    add_library(${target} STATIC ${cpp_sources})
endfunction()

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Source files
set(CORE_SOURCES
    core/compiler/lexer.seo
    core/compiler/parser.seo
    core/compiler/ast.seo
    core/compiler/codegen.seo
    core/compiler/error.seo
    core/compiler/type.seo
    core/compiler/symbol_table.seo
    core/compiler/scope.seo
    core/compiler/diagnostics.seo
    core/compiler/optimization.seo
    core/compiler/ir/builder.seo
    core/compiler/ir/module.seo
    core/compiler/ir/function.seo
    core/compiler/ir/basic_block.seo
    core/compiler/ir/instruction.seo
    core/compiler/ir/value.seo
    core/compiler/ir/type.seo
    core/compiler/passes/pass_manager.seo
    core/compiler/passes/dead_code_elimination.seo
    core/compiler/passes/constant_folding.seo
    core/compiler/passes/inlining.seo
    core/compiler/passes/loop_optimization.seo
)

set(COMMON_SOURCES
    core/common/config.seo
    core/common/error.seo
    core/common/logger.seo
    core/common/utils.seo
    core/common/file_system.seo
    core/common/string_utils.seo
    core/common/memory.seo
    core/common/thread_pool.seo
    core/common/profiler.seo
    core/common/timer.seo
)

set(RUNTIME_SOURCES
    runtime/vm/interpreter.seo
    runtime/vm/memory.seo
    runtime/vm/scheduler.seo
    runtime/vm/gc.seo
    runtime/vm/stack.seo
    runtime/vm/heap.seo
    runtime/vm/frame.seo
    runtime/vm/thread.seo
    runtime/vm/object.seo
    runtime/vm/class_loader.seo
    runtime/vm/native_interface.seo
    runtime/vm/jit/compiler.seo
    runtime/vm/jit/optimizer.seo
    runtime/vm/jit/cache.seo
    runtime/stdlib/math.seo
    runtime/stdlib/io.seo
    runtime/stdlib/string.seo
    runtime/stdlib/collections.seo
    runtime/stdlib/system.seo
    runtime/stdlib/time.seo
    runtime/stdlib/network.seo
)

set(QUANTUM_SOURCES
    quantum/circuit/simulator.seo
    quantum/circuit/optimizer.seo
    quantum/gates/basic.seo
    quantum/gates/controlled.seo
    quantum/gates/custom.seo
    quantum/state/vector.seo
    quantum/state/density_matrix.seo
    quantum/error/correction.seo
    quantum/error/mitigation.seo
    quantum/algorithms/grover.seo
    quantum/algorithms/shor.seo
    quantum/algorithms/vqe.seo
    quantum/algorithms/qaoa.seo
    quantum/optimization/gradient.seo
    quantum/optimization/parameter.seo
)

set(AI_SOURCES
    ai/neural/network.seo
    ai/neural/layers.seo
    ai/neural/optimizer.seo
    ai/neural/loss.seo
    ai/neural/activation.seo
    ai/neural/initializer.seo
    ai/neural/regularizer.seo
    ai/quantum/qnn.seo
    ai/quantum/hybrid.seo
    ai/quantum/encoding.seo
    ai/quantum/measurement.seo
    ai/training/dataset.seo
    ai/training/dataloader.seo
    ai/training/trainer.seo
    ai/training/validator.seo
    ai/models/transformer.seo
    ai/models/lstm.seo
    ai/models/gru.seo
    ai/models/attention.seo
)

set(BUILD_SOURCES
    build/package.seo
    build/dependency.seo
    build/target.seo
    build/project.seo
    build/workspace.seo
    build/toolchain.seo
    build/platform.seo
    build/artifact.seo
    build/repository.seo
    build/cache.seo
)

set(TEST_SOURCES
    tests/compiler/lexer_test.seo
    tests/compiler/parser_test.seo
    tests/compiler/ast_test.seo
    tests/compiler/codegen_test.seo
    tests/compiler/type_test.seo
    tests/compiler/optimization_test.seo
    tests/runtime/vm/interpreter_test.seo
    tests/runtime/vm/memory_test.seo
    tests/runtime/vm/gc_test.seo
    tests/runtime/stdlib/math_test.seo
    tests/quantum/circuit/simulator_test.seo
    tests/quantum/gates/basic_test.seo
    tests/quantum/algorithms/grover_test.seo
    tests/ai/neural/network_test.seo
    tests/ai/quantum/qnn_test.seo
    tests/ai/training/trainer_test.seo
    tests/build/package_test.seo
    tests/build/project_test.seo
)

# Create source directories
file(MAKE_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}/core/compiler
    ${CMAKE_CURRENT_BINARY_DIR}/core/common
    ${CMAKE_CURRENT_BINARY_DIR}/runtime/vm
    ${CMAKE_CURRENT_BINARY_DIR}/quantum/state
    ${CMAKE_CURRENT_BINARY_DIR}/ai/training
    ${CMAKE_CURRENT_BINARY_DIR}/build
)

# Build libraries
add_seo_library(seoggi_common ${COMMON_SOURCES})
add_seo_library(seoggi_compiler ${CORE_SOURCES})
add_seo_library(seoggi_runtime ${RUNTIME_SOURCES})
add_seo_library(seoggi_quantum ${QUANTUM_SOURCES})
add_seo_library(seoggi_ai ${AI_SOURCES})
add_seo_library(seoggi_build ${BUILD_SOURCES})

# Main executable
add_executable(seoggi core/main.seo)
target_link_libraries(seoggi PRIVATE
    seoggi_compiler
    seoggi_common
    seoggi_runtime
    seoggi_quantum
    seoggi_ai
    seoggi_build
    ${LLVM_LIBRARIES}
    ${Z3_LIBRARIES}
    ${LibEdit_LIBRARIES}
    ${ZLIB_LIBRARIES}
    ${LIBXML2_LIBRARIES}
    ${CURL_LIBRARIES}
    Threads::Threads
)

# Build tools
add_executable(seoc tools/compiler/seoc.seo)
target_link_libraries(seoc PRIVATE seoggi_compiler seoggi_common)

add_executable(seorun tools/runtime/seorun.seo)
target_link_libraries(seorun PRIVATE seoggi_runtime seoggi_common)

add_executable(seodoc tools/doc/seodoc.seo)
target_link_libraries(seodoc PRIVATE seoggi_compiler seoggi_common)

add_executable(seofmt tools/fmt/seofmt.seo)
target_link_libraries(seofmt PRIVATE seoggi_compiler seoggi_common)

add_executable(seotest tools/test/seotest.seo)
target_link_libraries(seotest PRIVATE seoggi_compiler seoggi_runtime seoggi_common)

add_executable(seobuild tools/build/seobuild.seo)
target_link_libraries(seobuild PRIVATE seoggi_build seoggi_common)

add_executable(seopack tools/package/seopack.seo)
target_link_libraries(seopack PRIVATE seoggi_build seoggi_common)

# Tests
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    enable_testing()
    add_executable(seoggi_tests ${TEST_SOURCES})
    target_link_libraries(seoggi_tests PRIVATE
        seoggi_common
        seoggi_compiler
        seoggi_runtime
        seoggi_quantum
        seoggi_ai
        seoggi_build
        GTest::GTest
        GTest::Main
    )
    add_test(NAME seoggi_unit_tests COMMAND seoggi_tests)
endif()

# Install targets and headers
install(DIRECTORY include/
    DESTINATION include/seoggi
    FILES_MATCHING PATTERN "*.h"
)

# Generate and install pkg-config file
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/seoggi.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/seoggi.pc
    @ONLY
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/seoggi.pc
    DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig
)

# Add uninstall target
if(NOT TARGET uninstall)
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
        @ONLY)
    add_custom_target(uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
endif()
