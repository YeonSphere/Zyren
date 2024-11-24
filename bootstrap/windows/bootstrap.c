#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <shlobj.h>
#include "../shared/compiler.h"

#define SEO_VERSION "0.1.0"
#define INSTALL_PATH "C:\\Program Files\\seoggi"
#define BIN_PATH "C:\\Program Files\\seoggi\\bin"
#define LIB_PATH "C:\\Program Files\\seoggi\\lib"
#define INCLUDE_PATH "C:\\Program Files\\seoggi\\include"

// Check if running as administrator
BOOL IsElevated() {
    BOOL fRet = FALSE;
    HANDLE hToken = NULL;
    if (OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken)) {
        TOKEN_ELEVATION Elevation;
        DWORD cbSize = sizeof(TOKEN_ELEVATION);
        if (GetTokenInformation(hToken, TokenElevation, &Elevation, sizeof(Elevation), &cbSize)) {
            fRet = Elevation.TokenIsElevated;
        }
    }
    if (hToken) {
        CloseHandle(hToken);
    }
    return fRet;
}

// Create directory with proper error handling
BOOL CreateDirectoryWithCheck(LPCSTR path) {
    if (!CreateDirectoryA(path, NULL)) {
        DWORD error = GetLastError();
        if (error != ERROR_ALREADY_EXISTS) {
            printf("Error creating directory %s: %lu\n", path, error);
            return FALSE;
        }
    }
    return TRUE;
}

int main(int argc, char *argv[]) {
    printf("Seoggi Bootstrap Installer v%s\n", SEO_VERSION);
    
    // Check if running as administrator
    if (!IsElevated()) {
        printf("Error: Please run as administrator (right-click, Run as administrator)\n");
        return 1;
    }

    // Create installation directories
    if (!CreateDirectoryWithCheck(INSTALL_PATH) ||
        !CreateDirectoryWithCheck(BIN_PATH) ||
        !CreateDirectoryWithCheck(LIB_PATH) ||
        !CreateDirectoryWithCheck(INCLUDE_PATH)) {
        return 1;
    }

    // Copy compiler components
    if (!CopyFileA("bootstrap.seo", INSTALL_PATH "\\bootstrap.seo", FALSE)) {
        printf("Error: Failed to copy bootstrap compiler\n");
        return 1;
    }
    
    if (!CopyFileA("install.seo", INSTALL_PATH "\\install.seo", FALSE)) {
        printf("Error: Failed to copy installer\n");
        return 1;
    }

    // Add to PATH
    char path[32768];
    GetEnvironmentVariable("PATH", path, sizeof(path));
    char new_path[32768];
    snprintf(new_path, sizeof(new_path), "%s;%s\\bin", path, INSTALL_PATH);
    
    // Update both system and user PATH
    if (!SetEnvironmentVariable("PATH", new_path)) {
        printf("Error: Failed to update PATH\n");
        return 1;
    }

    // Create registry entries for uninstallation
    HKEY hKey;
    if (RegCreateKeyEx(HKEY_LOCAL_MACHINE,
                      "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Seoggi",
                      0, NULL, 0, KEY_WRITE, NULL, &hKey, NULL) == ERROR_SUCCESS) {
        RegSetValueEx(hKey, "DisplayName", 0, REG_SZ, (BYTE*)"Seoggi Programming Language", 26);
        RegSetValueEx(hKey, "DisplayVersion", 0, REG_SZ, (BYTE*)SEO_VERSION, strlen(SEO_VERSION) + 1);
        RegSetValueEx(hKey, "InstallLocation", 0, REG_SZ, (BYTE*)INSTALL_PATH, strlen(INSTALL_PATH) + 1);
        RegCloseKey(hKey);
    }

    printf("Seoggi installed successfully!\n");
    printf("You can now use 'seo' command to compile Seoggi programs.\n");
    printf("Please restart your terminal to use the updated PATH.\n");

    return 0;
}
