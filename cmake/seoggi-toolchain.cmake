# Seoggi Language CMake Toolchain File

# Set system name
set(CMAKE_SYSTEM_NAME Linux)

# Specify Seoggi compiler
set(CMAKE_Seoggi_COMPILER "${CMAKE_SOURCE_DIR}/bin/seoggi")
set(CMAKE_Seoggi_COMPILER_ID "Seoggi")
set(CMAKE_Seoggi_COMPILER_VERSION "0.1.0")

# Define Seoggi compilation rules
set(CMAKE_Seoggi_COMPILE_OBJECT "<CMAKE_Seoggi_COMPILER> compile -o <OBJECT> <SOURCE>")
set(CMAKE_Seoggi_CREATE_SHARED_LIBRARY "<CMAKE_Seoggi_COMPILER> link -shared -o <TARGET> <OBJECTS>")
set(CMAKE_Seoggi_CREATE_STATIC_LIBRARY "<CMAKE_Seoggi_COMPILER> archive -o <TARGET> <OBJECTS>")

# Enable Seoggi language support
enable_language(Seoggi)

# Set Seoggi specific flags
set(CMAKE_Seoggi_FLAGS_DEBUG "-g -O0")
set(CMAKE_Seoggi_FLAGS_RELEASE "-O3")
set(CMAKE_Seoggi_FLAGS "${CMAKE_Seoggi_FLAGS} -std=seoggi23")

# Define Seoggi file extensions
set(CMAKE_Seoggi_SOURCE_FILE_EXTENSIONS seo)
set(CMAKE_Seoggi_LINKER_PREFERENCE 40)
set(CMAKE_Seoggi_OUTPUT_EXTENSION .o)

# Set Seoggi include path
set(CMAKE_Seoggi_INCLUDE_PATH "${CMAKE_SOURCE_DIR}/include")

# Define Seoggi standard library path
set(SEOGGI_STDLIB_PATH "${CMAKE_SOURCE_DIR}/std")
set(CMAKE_Seoggi_STANDARD_LIBRARIES "-lseoggi_runtime")
