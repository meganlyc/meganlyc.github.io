#!/bin/bash

# Directory containing the image files
IMAGE_DIR="assets/images"

# Function to generate a random file name
generate_random_name() {
    echo "$(date +%s%N | sha256sum | base64 | head -c 16)"
}

# Function to find and replace file names
find_and_replace() {
    local old_name=$1
    local new_name=$2
    # Find and replace in all files in the directory and subdirectories
    find $IMAGE_DIR -type f -exec sed -i "s/$old_name/$new_name/g" {} \;
}

# Loop through image files
find $IMAGE_DIR -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif \) | while read file; do
    filename=$(basename "$file")
    extension="${filename##*.}"
    name="${filename%.*}"
    
    # Check if the file name length is too long (e.g., more than 50 characters)
    if [ ${#name} -gt 50 ]; then
        echo "File name too long: $filename"
        
        # Generate a new file name
        new_name=$(generate_random_name)
        new_filename="$new_name.$extension"
        
        # Remember the old and new file names
        echo "Renaming $filename to $new_filename"
        
        # Rename the file
        mv "$file" "$(dirname "$file")/$new_filename"
        
        # Find and replace the old name with the new name in other files
        find_and_replace "$filename" "$new_filename"
    fi
done

echo "Process completed."
