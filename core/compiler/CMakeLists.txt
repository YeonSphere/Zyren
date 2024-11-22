add_executable(seoggi_compiler
    type_checker.cpp
    smt.cpp
)

target_include_directories(seoggi_compiler
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(seoggi_compiler
    PRIVATE
    ${LLVM_LIBRARIES}
    ${Z3_LIBRARIES}
)

if(LibEdit_FOUND)
    target_link_libraries(seoggi_compiler PRIVATE ${LibEdit_LIBRARIES})
endif()

install(TARGETS seoggi_compiler
    RUNTIME DESTINATION bin
)
