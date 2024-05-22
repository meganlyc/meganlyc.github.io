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

# Loop through all HTML files in the specified directory
for FILE in "$DIRECTORY"/*.html; do
    # Check if file exists
    if [ -f "$FILE" ]; then
        # Use sed to insert the JavaScript just before the closing </body> tag
        sed -i "/<\/body>/i <script>${JS_TO_ADD}<\/script>" "$FILE"
        echo "Updated $FILE"
    fi
done

# Commit and push the changes with the temporary git committer
git add .
git commit -m "update"
git push

# Restore the original git committer name and email
set_git_committer "$original_name" "$original_email"

echo "All HTML files have been updated, and the original Git committer information is restored."
