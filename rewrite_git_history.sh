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
#!/bin/bash

# ---------------------------------------------
# Script: rewrite_git_history.sh
# Description: Rewrites all Git commit messages in the repository's history
#              to be more meaningful and varied based on changed files.
# Usage: ./rewrite_git_history.sh
# ---------------------------------------------

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display error messages
error() {
    echo "❌ Error: $1"
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Check if Git is installed
if ! command_exists git; then
    error "Git is not installed. Please install Git to use this script."
fi

# 2. Check if git-filter-repo is installed
if ! command_exists git-filter-repo; then
    error "git-filter-repo is not installed."
    echo "   You can install it using pip:"
    echo "   pip install git-filter-repo"
    exit 1
fi

# 3. Check if the current directory is inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    error "This script must be run inside a Git repository."
fi

# 4. Check if the working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have unstaged or uncommitted changes."
    read -p "   Do you want to continue and stash the changes? (yes/no): " stash_response
    if [[ "$stash_response" =~ ^(yes|y)$ ]]; then
        git stash save "Temporary stash before Git history rewrite"
        echo "✅ Changes have been stashed."
    else
        error "Please commit or stash your changes before running this script."
    fi
fi

# 5. Prompt for user confirmation
echo ""
echo "⚠️  **Warning:** Rewriting Git history is a destructive operation."
echo "   It will change all commit hashes and can disrupt collaborators."
read -p "   Are you sure you want to proceed? (yes/no): " confirmation

if [[ "$confirmation" != "yes" && "$confirmation" != "y" ]]; then
    echo "Operation aborted by the user."
    exit 0
fi

# 6. Optional: Create a backup branch
read -p "   Do you want to create a backup branch before rewriting history? (yes/no): " backup_response
if [[ "$backup_response" =~ ^(yes|y)$ ]]; then
    backup_branch="backup-before-rewrite-$(date +%Y%m%d%H%M%S)"
    git checkout -b "$backup_branch"
    echo "✅ Backup branch '$backup_branch' created."
    git checkout main  # Replace 'main' with your default branch if different
fi

# 7. Define the message callback
# This Python code will be passed to git-filter-repo to rewrite commit messages
read -r -d '' MESSAGE_CALLBACK << 'EOF'
import random

# Define a list of message templates
messages = [
    "Updated the following files: {files}",
    "Modified files: {files}",
    "Refined code in: {files}",
    "Tweaked and improved: {files}",
    "Minor adjustments in: {files}",
    "Enhanced functionality for: {files}",
    "Code refactoring in files: {files}",
    "Applied changes to: {files}",
    "Polished up: {files}",
    "Maintenance update for: {files}",
]

# Retrieve the list of changed files in the commit
changed_files = [change.name.decode("utf-8") for change in commit.file_changes]

if not changed_files:
    # Default message if no files were changed
    new_message = "No changes detected in this commit."
else:
    # Choose a random message template
    template = random.choice(messages)
    # Join the file names into a comma-separated string
    files_str = ", ".join(changed_files)
    # Generate the new commit message
    new_message = template.format(files=files_str)

# Return the new commit message as bytes
new_message.encode("utf-8")
EOF

# 8. Run git-filter-repo with the message callback
echo ""
echo "🔄 Rewriting Git history with meaningful commit messages..."
git filter-repo --force --message-callback "$MESSAGE_CALLBACK"

# 9. Post-rewrite instructions
echo ""
echo "✅ Git history successfully rewritten with meaningful commit messages."

echo ""
echo "⚠️  **Important:** You need to force push the changes to your remote repository."
echo "   Use the following command:"
echo "   git push --force origin main  # Replace 'main' with your branch name if different"

echo ""
echo "📌 If you created a backup branch, it remains intact as '$backup_branch'."
echo "   If you encounter issues, you can switch back to it using:"
echo "   git checkout $backup_branch"
echo ""

# Optional: Remind to apply stashed changes
if git stash list | grep -q "Temporary stash before Git history rewrite"; then
    echo "🔔 Reminder: You have stashed changes. Apply them using:"
    echo "   git stash pop"
fi

exit 0


# Restore the original git committer name and email
set_git_committer "$original_name" "$original_email"

echo "All HTML files have been updated, and the original Git committer information is restored."
