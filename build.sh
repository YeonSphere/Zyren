#!/bin/bash

# Seoggi Build Script

# Function to build the project
build_project() {
    echo "Building Seoggi..."
    # Add build commands here
}

# Function to update Seoggi from GitHub
update_project() {
    echo "Do you want to update Seoggi from GitHub? (y/n) "
    read -r update_choice
    case "$update_choice" in
        y|Y )
            echo "Updating Seoggi from GitHub..."
            if git pull origin master; then
                echo "Update successful."
                echo "Building Seoggi..."
                build_project
                echo "Build complete. Would you like to run the installer? (y/n) "
                read -r choice
                case "$choice" in
                    y|Y )
                        echo "Running installer..."
                        ./installer.seo
                        ;;
                    n|N )
                        echo "Installer skipped."
                        ;;
                    * )
                        echo "Invalid choice."
                        ;;
                esac
            else
                echo "Update failed. Please check your connection or repository status."
            fi
            ;;
        n|N )
            echo "Update skipped."
            ;;
        * )
            echo "Invalid choice."
            ;;
    esac
}

# Run the update function
update_project
