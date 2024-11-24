# Function to check if seo compiler is available
function(check_seo_compiler)
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/tools/seo")
        message(FATAL_ERROR "Seoggi compiler not found at ${CMAKE_SOURCE_DIR}/tools/seo. Please ensure it is installed.")
    endif()
endfunction()

# Custom function to compile .seo files
function(add_seoggi_library target)
    check_seo_compiler()

    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs SOURCES INCLUDES DEPENDS)
    cmake_parse_arguments(SEOGGI "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT SEOGGI_SOURCES)
        message(FATAL_ERROR "No source files provided for target ${target}")
    endif()

    set(output_files)
    foreach(source ${SEOGGI_SOURCES})
        get_filename_component(name ${source} NAME_WE)
        get_filename_component(abs_source "${CMAKE_CURRENT_SOURCE_DIR}/${source}" ABSOLUTE)
        set(output "${CMAKE_CURRENT_BINARY_DIR}/${name}.o")

        add_custom_command(
            OUTPUT ${output}
            COMMAND ${CMAKE_SOURCE_DIR}/tools/seo compile
                -o ${output}
                ${abs_source}
                $<$<BOOL:${SEOGGI_INCLUDES}>:-I$<JOIN:${SEOGGI_INCLUDES}, -I>>
            DEPENDS 
                ${abs_source}
                ${SEOGGI_DEPENDS}
                ${CMAKE_SOURCE_DIR}/tools/seo
            COMMENT "Compiling ${source}"
            VERBATIM
        )
        list(APPEND output_files ${output})
    endforeach()

    add_library(${target} STATIC ${output_files})
    if(SEOGGI_INCLUDES)
        target_include_directories(${target} PUBLIC ${SEOGGI_INCLUDES})
    endif()
    if(SEOGGI_DEPENDS)
        add_dependencies(${target} ${SEOGGI_DEPENDS})
    endif()
endfunction()
