#!/bin/bash

# Determine the new version of Veracode CLI from the CI commit tag
if [[ ${CI_COMMIT_TAG:0:1} == "v" ]]; then
  VERSION=${CI_COMMIT_TAG:1}
else
  VERSION=$CI_COMMIT_TAG
fi

# Initialize variables for SHA256 checksums
SHA256_MACOS_ARM64=""
SHA256_MACOS_X86=""
SHA256_LINUX_X86=""

# Verify that checksums.txt exists
CHECKSUMS_FILE="checksums.txt"
if [[ ! -f "$CHECKSUMS_FILE" ]]; then
  echo "Error: checksums.txt file not found"
  exit 1
fi

# Extract SHA256 checksums from checksums.txt
index=1
total_len=$(awk 'END { print NR }' "$CHECKSUMS_FILE")
while [ $index -le $total_len ]; do
    arc=$(awk "NR==$index {printf \$2 \" \"}" "$CHECKSUMS_FILE")
    if [[ $arc == *"linux_x86"* ]]; then
        SHA256_LINUX_X86=$(awk "NR==$index {printf \$1}" "$CHECKSUMS_FILE")
    elif [[ $arc == *"macosx_arm64"* ]]; then
        SHA256_MACOS_ARM64=$(awk "NR==$index {printf \$1}" "$CHECKSUMS_FILE")
    elif [[ $arc == *"macosx_x86"* ]]; then
        SHA256_MACOS_X86=$(awk "NR==$index {printf \$1}" "$CHECKSUMS_FILE")
    fi
    ((index++))
done

# Path to the updated formula
UPDATED_FORMULA_PATH="formula/veracode-cli.rb"

# Function to update the formula for a specific version
update_formula() {
  local version=$1
  local formula_name="veracode-cli@${version}.rb"

  # Replace placeholders with actual values
  sed "s/VERSION_PLACEHOLDER/$version/g; \
       s/SHA256_MACOS_ARM64_PLACEHOLDER/$SHA256_MACOS_ARM64/g; \
       s/SHA256_MACOS_X86_PLACEHOLDER/$SHA256_MACOS_X86/g; \
       s/SHA256_LINUX_X86_PLACEHOLDER/$SHA256_LINUX_X86/g" \
      "$UPDATED_FORMULA_PATH" > "$formula_name"
}

# Check if veracode-cli.rb already exists
if [[ -f veracode-cli.rb ]]; then
  # Extract the existing version from the formula
  EXISTING_VERSION=$(awk 'NR==4 {print $2}' veracode-cli.rb | tr -d '"')

  # Rename the existing formula file
  mv veracode-cli.rb "veracode-cli@${EXISTING_VERSION}.rb"
fi

# Update the formula for the new version
update_formula "$VERSION"

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
