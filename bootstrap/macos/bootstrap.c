#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <pwd.h>
#include "../shared/compiler.h"

#define SEO_VERSION "0.1.0"
#define INSTALL_PATH "/usr/local/seoggi"
#define BIN_PATH "/usr/local/seoggi/bin"
#define LIB_PATH "/usr/local/seoggi/lib"
#define INCLUDE_PATH "/usr/local/seoggi/include"

void create_dir(const char* path) {
    mkdir(path, 0755);
}

int main(int argc, char *argv[]) {
    printf("Seoggi Bootstrap Installer v%s\n", SEO_VERSION);
    
    // Check if running as root
    if (geteuid() != 0) {
        printf("Error: Please run as root (sudo ./seo-install)\n");
        return 1;
    }

    // Create installation directories
    create_dir(INSTALL_PATH);
    create_dir(BIN_PATH);
    create_dir(LIB_PATH);
    create_dir(INCLUDE_PATH);

    // Copy compiler components
    system("cp bootstrap.seo " INSTALL_PATH "/bootstrap.seo");
    system("cp install.seo " INSTALL_PATH "/install.seo");
    
    // Create seo command symlink
    system("ln -sf " INSTALL_PATH "/bin/seo /usr/local/bin/seo");
    
    // Set permissions
    system("chmod 755 " INSTALL_PATH "/bin/seo");
    
    // Update PATH in profile
    FILE* profile = fopen("/etc/paths.d/seoggi", "w");
    if (profile) {
        fprintf(profile, "%s/bin\n", INSTALL_PATH);
        fclose(profile);
    }

    // Handle both x86_64 and ARM64
    #ifdef __aarch64__
    printf("Installing for Apple Silicon (ARM64)\n");
    #else
    printf("Installing for Intel (x86_64)\n");
    #endif

    printf("Seoggi installed successfully!\n");
    printf("Please open a new terminal window to use the 'seo' command.\n");

    return 0;
}
