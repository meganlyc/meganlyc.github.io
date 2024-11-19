#!/bin/bash

# clean up
bash cleanup_long_files.sh

# Directory containing HTML files
DIRECTORY="./"

# JavaScript to be added, broken down for sed
JS_TO_ADD="window.onload = function() {"
JS_TO_ADD+=" var element = document.querySelector('section.display-7 a[href=\\\"https://mobiri.se/2706489\\\"]');"
JS_TO_ADD+=" if (element && element.parentElement) {"
JS_TO_ADD+=" element.parentElement.remove();"
JS_TO_ADD+=" }"
JS_TO_ADD+="};"

# Function to set git committer information
set_git_committer() {
    git config user.name "$1"
    git config user.email "$2"
}

# Get the original git committer name and email
original_name=$(git config user.name)
original_email=$(git config user.email)

# Print the original git committer name and email
echo "Original Git Committer Name: $original_name"
echo "Original Git Committer Email: $original_email"

# Save the original git committer name and email to a file
echo "Saving original Git committer information to a file..."
echo "Name: $original_name" > git_committer_info.txt
echo "Email: $original_email" >> git_committer_info.txt

# Set the temporary git committer's name and email
temporary_name="Megan Li"
temporary_email="liyuchenlyc2022@163.com"

# Modify the git committer temporarily for the script
set_git_committer "$temporary_name" "$temporary_email"

# Track changes
added_files=0
updated_files=0
removed_files=0

# Loop through all HTML files in the specified directory
for FILE in "$DIRECTORY"/*.html; do
    # Check if file exists
    if [ -f "$FILE" ]; then
        # Check if this is a new file
        if git ls-files --others --exclude-standard | grep -q "$FILE"; then
            added_files=$((added_files + 1))
            git add "$FILE"
            echo "Added $FILE"
        else
            # Update existing files
            sed -i "/<\/body>/i <script>${JS_TO_ADD}<\/script>" "$FILE"
            updated_files=$((updated_files + 1))
            echo "Updated $FILE"
        fi
    fi
done

# Detect removed files
for FILE in $(git ls-files); do
    if [ ! -f "$FILE" ]; then
        removed_files=$((removed_files + 1))
        git rm "$FILE"
        echo "Removed $FILE"
    fi
done

# Generate dynamic commit message based on changes
commit_message=""

if [ "$added_files" -gt 0 ]; then
    commit_message+="Added $added_files new file(s). "
fi

if [ "$updated_files" -gt 0 ]; then
    commit_message+="Updated $updated_files existing file(s). "
fi

if [ "$removed_files" -gt 0 ]; then
    commit_message+="Removed $removed_files file(s). "
fi

if [ -z "$commit_message" ]; then
    commit_message="No significant changes."
fi

# Commit and push the changes with the temporary git committer
git add .
git commit -m "$commit_message"
git push

# Restore the original git committer name and email
set_git_committer "$original_name" "$original_email"

echo "All changes have been processed:"
echo " - Added files: $added_files"
echo " - Updated files: $updated_files"
echo " - Removed files: $removed_files"
echo "Original Git committer information is restored."
