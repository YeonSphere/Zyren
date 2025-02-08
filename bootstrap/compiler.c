#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char* source;
    size_t length;
    const char* filename;
} SourceFile;

typedef struct {
    const char* message;
    int line;
    int column;
} CompileError;

SourceFile read_source_file(const char* path) {
    FILE* file = fopen(path, "rb");
    if (!file) {
        fprintf(stderr, "Error: Could not open %s\n", path);
        exit(1);
    }
    
    fseek(file, 0, SEEK_END);
    size_t size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    char* buffer = malloc(size + 1);
    fread(buffer, 1, size, file);
    buffer[size] = '\0';
    fclose(file);
    
    return (SourceFile){buffer, size, path};
}

int compile_file(SourceFile source, const char* output_path) {
    printf("Compiling %s...\n", source.filename);
    // Basic compilation implementation
    return 0;
}

int main(int argc, char** argv) {
    if (argc != 3) {
        printf("Usage: seoggi-bootstrap <source> -o <output>\n");
        return 1;
    }
    
    SourceFile source = read_source_file(argv[1]);
    int result = compile_file(source, argv[3]);
    free(source.source);
    return result;
}
