#!/bin/bash

GIT_USER=""
GIT_BASE_SSH_PATH="git@github.com"

REPO_BASE_DIR="./repos"
REPOS_YAML_PATH="./repos.yaml"
REPOS=""

init() {
    # Check if repos directory exists and is not empty
    if [ -d "${REPO_BASE_DIR}" ] && [ "$(ls -A ${REPO_BASE_DIR})" ]; then
        read -rp "Repository directory exists and is not empty. Do you want to delete it? (y/N): " response
        case "$(echo "$response" | tr '[:upper:]' '[:lower:]')" in
            y|yes)
                sudo rm -rf "${REPO_BASE_DIR}"
                mkdir -p "${REPO_BASE_DIR}"
                ;;
            *)
                echo "Exiting without changes."
                exit 0
                ;;
        esac
    else
        mkdir -p "${REPO_BASE_DIR}"
    fi

    # Check if repos.yaml exists
    if [ ! -f "${REPOS_YAML_PATH}" ]; then
        echo "Required repos.yaml file not found"
        exit 1
    fi

    # Prompt user for git username until non-empty input is provided
    while [[ -z "$GIT_USER" ]]; do
        read -rp "Enter your Git username: " GIT_USER
        if [[ -z "$GIT_USER" ]]; then
            echo "Git username cannot be empty. Please enter your Git username."
        fi
    done

    # Get the list of repositories
    REPOS=$(yq eval '.repositories[]' "$REPOS_YAML_PATH")
}

clone-repos() {
    for REPO in $REPOS; do
        REPO_PATH="$REPO_BASE_DIR/$REPO"
        FORK_URL="$GIT_BASE_SSH_PATH:$GIT_USER/$REPO.git"

        echo "Cloning your fork of $REPO..."
        git clone "$FORK_URL" "$REPO_PATH"
        if [ $? -ne 0 ]; then
            echo "Error cloning $FORK_URL, skipping..."
            continue
        fi

        # Initialize and update submodules
        update-submodules "$REPO_PATH"
    done

    echo "All repositories cloned and submodules updated successfully!"
}

update-submodules() {
    local repo_path="$1"
    echo "Updating submodules in $repo_path..."
    
    git -C "$repo_path" submodule update --init --recursive

    if [ $? -ne 0 ]; then
        echo "Failed to update submodules in $repo_path"
    else
        echo "Submodules updated successfully in $repo_path"
    fi
}

init
clone-repos
