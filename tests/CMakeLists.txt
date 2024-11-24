cmake_minimum_required(VERSION 3.20)

# Enable testing
enable_testing()

# Find GTest package
find_package(GTest REQUIRED)
include(GoogleTest)

# Collect all test source files
file(GLOB_RECURSE TEST_SOURCES
    "*.cpp"
    "*.cc"
    "*.seo"
)

# Create test executable
add_executable(seoggi_tests ${TEST_SOURCES})

# Link against GTest and our library
target_link_libraries(seoggi_tests
    PRIVATE
    GTest::GTest
    GTest::Main
    seoggi_core
    seoggi_compiler
)

# Add tests to CTest
gtest_discover_tests(seoggi_tests)
