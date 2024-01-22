#!/bin/bash

# Directory containing HTML files
DIRECTORY="./"

# JavaScript to be added, broken down for sed
JS_TO_ADD="window.onload = function() {"
JS_TO_ADD+=" var element = document.querySelector('section.display-7 a[href=\\\"https://mobiri.se/2706489\\\"]');"
JS_TO_ADD+=" if (element && element.parentElement) {"
JS_TO_ADD+=" element.parentElement.remove();"
JS_TO_ADD+=" }"
JS_TO_ADD+="};"

# Loop through all HTML files in the specified directory
for FILE in "$DIRECTORY"/*.html; do
    # Check if file exists
    if [ -f "$FILE" ]; then
        # Use sed to insert the JavaScript just before the closing </body> tag
        sed -i "/<\/body>/i <script>${JS_TO_ADD}<\/script>" "$FILE"
        echo "Updated $FILE"
    fi
done

echo "All HTML files have been updated."

git add .
git commit -m "update"
git push