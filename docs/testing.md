# Seoggi Testing Guide

Seoggi provides comprehensive testing capabilities through built-in commands and a robust test framework.

## Test Commands

### Running Tests
```bash
# Run all tests
seo test

# Run tests in sequence (no parallelization)
seo test --no-parallel

# Run specific test types
seo test --type unit
seo test --type integration
seo test --type property
seo test --type fuzz
seo test --type benchmark

# Filter tests by name
seo test --filter "lexer"
```

### Coverage Testing
```bash
# Run tests with coverage reporting
seo test-coverage
```

### Benchmarking
```bash
# Run benchmarks
seo bench
```

### Fuzzing
```bash
# Run fuzzing tests
seo fuzz

# Configure fuzzing limits
seo fuzz --time 3600    # Run for 1 hour
seo fuzz --memory 1024  # Limit to 1GB memory
```

### Property Testing
```bash
# Run property-based tests
seo check

# Configure property test parameters
seo check --tests 1000    # Run 1000 test cases
seo check --shrinks 200   # Allow 200 shrinking attempts
```

## Writing Tests

### Unit Tests
```seoggi
#[test]
fn test_addition() -> Result<(), Error> {
    assert_eq!(2 + 2, 4)
    Ok(())
}

#[test]
#[should_panic]
fn test_division_by_zero() {
    let _ = 1 / 0
}

#[test]
#[timeout(1)]
fn test_performance() -> Result<(), Error> {
    // Should complete within 1 second
    Ok(())
}
```

### Property Tests
```seoggi
#[test]
#[property_test]
fn test_reverse_list(list: Vec<i32>) -> Result<(), Error> {
    let reversed = list.reverse()
    let double_reversed = reversed.reverse()
    assert_eq!(list, double_reversed)
    Ok(())
}
```

### Fuzzing Tests
```seoggi
#[test]
#[fuzz_test]
fn test_parser_robustness(data: &[u8]) {
    if let Ok(input) = String::from_utf8(data.to_vec()) {
        let _ = parse_expression(&input)  // Should not crash
    }
}
```

### Benchmarks
```seoggi
#[test]
#[benchmark]
fn bench_sorting() -> Result<(), Error> {
    let mut data = generate_random_data(1000)
    b.iter(|| {
        data.sort()
    })
    Ok(())
}
```

## Test Organization

### Directory Structure
```
seoggi/
├── tests/
│   ├── unit/
│   │   ├── lexer_test.seo
│   │   ├── parser_test.seo
│   │   └── type_checker_test.seo
│   ├── integration/
│   │   └── compiler_test.seo
│   ├── property/
│   │   └── invariants_test.seo
│   └── bench/
│       └── performance_test.seo
```

### Test Configuration
```seoggi
// In project.seo
testing: {
    parallel: true
    test_dirs: [
        "tests/unit",
        "tests/integration",
        "tests/property",
        "tests/bench"
    ]
    exclude: [
        "tests/experimental"
    ]
}
```

## Best Practices

1. **Test Organization**
   - Group related tests in the same file
   - Use descriptive test names
   - Keep test files focused and manageable

2. **Test Coverage**
   - Aim for high code coverage
   - Test edge cases and error conditions
   - Include both positive and negative tests

3. **Performance Testing**
   - Write benchmarks for critical paths
   - Monitor performance regressions
   - Test with realistic data sizes

4. **Property Testing**
   - Identify and test invariants
   - Use appropriate generators
   - Handle edge cases in properties

5. **Fuzzing**
   - Focus on parsing and data handling
   - Use corpus-based fuzzing
   - Track and analyze crashes

## Advanced Features

### Custom Test Attributes
```seoggi
#[test]
#[requires(feature = "advanced")]
#[depends_on("database")]
fn test_database_integration() -> Result<(), Error> {
    // Test implementation
}
```

### Test Fixtures
```seoggi
#[fixture]
fn setup_database() -> Database {
    // Setup code
}

#[test]
#[use_fixture(setup_database)]
fn test_with_database(db: Database) -> Result<(), Error> {
    // Test using database
}
```

### Test Categories
```seoggi
#[test]
#[category("slow")]
fn test_long_running() -> Result<(), Error> {
    // Long-running test
}

// Run with: seo test --filter-category "slow"
```

### Custom Assertions
```seoggi
#[test]
fn test_with_custom_assertions() -> Result<(), Error> {
    assert_approx_eq!(3.14159, pi(), 0.00001)
    assert_ordered!(vec![1, 2, 3, 4])
    assert_contains!(haystack, needle)
    Ok(())
}
```

## Continuous Integration

### GitHub Actions Example
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          seo test
          seo test-coverage
      - name: Upload coverage
        uses: codecov/codecov-action@v1
```

## Debugging Tests

### Debug Output
```seoggi
#[test]
fn test_with_debug() -> Result<(), Error> {
    debug!("Testing step 1")
    // Test code
    debug!("Testing step 2: {:?}", result)
    Ok(())
}
```

### Test-Specific Logging
```seoggi
#[test]
#[log_level("debug")]
fn test_with_logging() -> Result<(), Error> {
    // Test with debug logging enabled
}
```

## Contributing

When adding new tests:
1. Follow the existing test organization
2. Include appropriate documentation
3. Ensure tests are deterministic
4. Add test cases to cover new features
5. Update test documentation as needed
