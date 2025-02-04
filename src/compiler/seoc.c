#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Compiler version
#define SEOC_VERSION "0.1.0"

// Function declarations
void print_version(void);
void print_usage(void);
int compile_file(const char* input_file, const char* output_file);

int main(int argc, char* argv[]) {
    if (argc < 2) {
        print_usage();
        return 1;
    }

    // Handle command line arguments
    if (strcmp(argv[1], "--version") == 0 || strcmp(argv[1], "-v") == 0) {
        print_version();
        return 0;
    }

    if (argc < 3) {
        fprintf(stderr, "Error: No output file specified\n");
        print_usage();
        return 1;
    }

    return compile_file(argv[1], argv[2]);
}

void print_version(void) {
    printf("seoc version %s\n", SEOC_VERSION);
}

void print_usage(void) {
    printf("Usage: seoc <input_file> <output_file>\n");
    printf("Options:\n");
    printf("  --version, -v    Print version information\n");
}

int compile_file(const char* input_file, const char* output_file) {
    FILE* in = fopen(input_file, "r");
    if (!in) {
        fprintf(stderr, "Error: Could not open input file '%s'\n", input_file);
        return 1;
    }

    FILE* out = fopen(output_file, "w");
    if (!out) {
        fclose(in);
        fprintf(stderr, "Error: Could not open output file '%s'\n", output_file);
        return 1;
    }

    // TODO: Implement actual compilation
    // For now, just copy the input file to output
    char buffer[4096];
    size_t bytes;
    while ((bytes = fread(buffer, 1, sizeof(buffer), in)) > 0) {
        fwrite(buffer, 1, bytes, out);
    }

    fclose(in);
    fclose(out);
    
    printf("Compiled %s -> %s\n", input_file, output_file);
    return 0;
}
