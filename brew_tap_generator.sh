#!/bin/bash

# Set the new version of Veracode CLI
NEW_VERSION="2.28.0"

# Path to the updated formula
UPDATED_FORMULA_PATH="formula/veracode-cli.rb"

# Function to create or update the formula for a specific version
update_formula() {
  local version=$1
  local formula_name="veracode-cli@${version}.rb"
  
  if [[ $version == $NEW_VERSION ]]; then
    cp -f "$UPDATED_FORMULA_PATH" "$formula_name"
  else
    # Modify the formula for the specific version
    cp -f "$UPDATED_FORMULA_PATH" "$formula_name"
    sed -i '' "s/version \"$NEW_VERSION\"/version \"$version\"/" "$formula_name"
    # Add more sed commands to modify URLs and SHA256 as needed for different versions
  fi
}

# Check if veracode-cli.rb already exists
if [[ -f veracode-cli.rb ]]; then
  # Extract the existing version from the formula
  EXISTING_VERSION=$(awk 'NR==4 {print $2}' veracode-cli.rb | tr -d '"')
  
  # Rename the existing formula file
  mv veracode-cli.rb "veracode-cli@${EXISTING_VERSION}.rb"
fi

# Update the formula for the new version
update_formula "$NEW_VERSION"

# List and sort veracode-cli files by version
VERACODE_FILES=($(ls veracode-cli* | sort -V))

# Count the number of versioned files
FILE_COUNT=${#VERACODE_FILES[@]}

# Keep only the 5 most recent versions by removing the oldest
if [[ $FILE_COUNT -gt 5 ]]; then
  FILES_TO_REMOVE=$((FILE_COUNT - 5))
  for ((i=0; i<$FILES_TO_REMOVE; i++)); do
    rm -f "${VERACODE_FILES[$i]}"
  done
fi

# Print completion message
echo "Homebrew tap formula updated and managed successfully."
