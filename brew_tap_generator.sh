#!/bin/bash

# Verify that checksums.txt exists
CHECKSUMS_FILE="checksums.txt"
if [[ ! -f "$CHECKSUMS_FILE" ]]; then
  echo "Error: checksums.txt file not found"
  exit 1
fi

# Initialize variables for SHA256 checksums and version
SHA256_MACOS_ARM64=""
SHA256_MACOS_X86=""
SHA256_LINUX_X86=""
VERSION=""

# Extract SHA256 checksums and version from checksums.txt
index=1
total_len=$(awk 'END { print NR }' "$CHECKSUMS_FILE")
while [ $index -le $total_len ]; do
    line=$(awk "NR==$index {print}" "$CHECKSUMS_FILE")
    checksum=$(echo "$line" | awk '{print $1}')
    arc=$(echo "$line" | awk '{print $2}')

    if [[ $arc == *"linux_x86"* ]]; then
        SHA256_LINUX_X86=$checksum
    elif [[ $arc == *"macosx_arm64"* ]]; then
        SHA256_MACOS_ARM64=$checksum
    elif [[ $arc == *"macosx_x86"* ]]; then
        SHA256_MACOS_X86=$checksum
    fi

    # Extract version from filename
    if [[ -z $VERSION ]]; then
        if [[ $arc =~ veracode-cli_([0-9]+\.[0-9]+\.[0-9]+)_ ]]; then
            VERSION=${BASH_REMATCH[1]}
        fi
    fi

    ((index++))
done

# Verify that a version was found
if [[ -z $VERSION ]]; then
  echo "Error: Could not extract version from checksums.txt"
  exit 1
fi

# Path to the updated formula
UPDATED_FORMULA_PATH="formula/veracode-cli.rb"

# Function to update the formula for a specific version
update_formula() {
  local VERSION=$1
  local formula_name="veracode-cli@${VERSION}.rb"

  # Replace placeholders with actual values
  sed "s/VERSION_PLACEHOLDER/$VERSION/g; \
       s/SHA256_MACOS_ARM64_PLACEHOLDER/$SHA256_MACOS_ARM64/g; \
       s/SHA256_MACOS_X86_PLACEHOLDER/$SHA256_MACOS_X86/g; \
       s/SHA256_LINUX_X86_PLACEHOLDER/$SHA256_LINUX_X86/g" \
      "$UPDATED_FORMULA_PATH" > "$formula_name"
}

# Check if veracode-cli.rb already exists
if [[ -f veracode-cli.rb ]]; then
  # Extract the existing version from the formula
  EXISTING_VERSION=$(awk '/^  version/ {print $2}' veracode-cli.rb | tr -d '"')

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
