#!/bin/bash

# Determine the new version of Veracode CLI from the CI commit tag
if [[ ${CI_COMMIT_TAG:0:1} == "v" ]]
then
  VERSION=${CI_COMMIT_TAG:1}
else
  VERSION=$CI_COMMIT_TAG
fi

# Path to the formula directory
FORMULA_DIR="formula"

# Extract the previous version 
PREVIOUS_VERSION=$(awk 'NR==4 {print $2}' "$FORMULA_DIR/veracode-cli.rb" | tr -d '"')

# Find the oldest version file in the formula directory
OLDEST_VERSION_FILE=$(ls "$FORMULA_DIR/veracode-cli@*.rb" | sort -V | head -n 1)

# Rename the oldest version file to the previous version
mv "$OLDEST_VERSION_FILE" "$FORMULA_DIR/veracode-cli@$PREVIOUS_VERSION.rb"

# Extract SHA256 values for all architectures from the current cli.rb
SHA256_MACOS_ARM64=$(awk '/arm64/ {getline; print $2}' "$FORMULA_DIR/veracode-cli.rb" | tr -d '"')
SHA256_MACOS_X86=$(awk '/x86/ && /macosx/ {getline; print $2}' "$FORMULA_DIR/veracode-cli.rb" | tr -d '"')
SHA256_LINUX_X86=$(awk '/x86/ && /linux/ {getline; print $2}' "$FORMULA_DIR/veracode-cli.rb" | tr -d '"')

# Update version and SHA256 values in the renamed file
sed -i "s/^  version \".*\"/  version \"$PREVIOUS_VERSION\"/g" "$FORMULA_DIR/veracode-cli@$PREVIOUS_VERSION.rb"
sed -i "s/^      sha256 \".*\"/      sha256 \"$SHA256_MACOS_ARM64\"/g" "$FORMULA_DIR/veracode-cli@$PREVIOUS_VERSION.rb"
sed -i "s/^      sha256 \".*\"/      sha256 \"$SHA256_MACOS_X86\"/g" "$FORMULA_DIR/veracode-cli@$PREVIOUS_VERSION.rb"
sed -i "s/^    sha256 \".*\"/    sha256 \"$SHA256_LINUX_X86\"/g" "$FORMULA_DIR/veracode-cli@$PREVIOUS_VERSION.rb"

# Move the current cli.rb to a versioned file
mv "$FORMULA_DIR/veracode-cli.rb" "$FORMULA_DIR/veracode-cli@$VERSION.rb"

echo "Homebrew formula files have been updated successfully."

git clone https://github.com/veracode/${HOMEBREW_REPO}.git

# Define variables
NEW_BRANCH="update-formula-$PREVIOUS_VERSION"
PR_TITLE="Update Homebrew Formula to $PREVIOUS_VERSION"
PR_BODY="This PR updates the Homebrew formula to the version $PREVIOUS_VERSION."

# Navigate to the formula directory (optional, if you are not already in the root directory)
cd ${HOMEBREW_REPO}/Formula

# Check if there are any changes
if [[ -n $(git status --porcelain) ]]; then
  # Create a new branch
  git checkout -b "$NEW_BRANCH"

  # Add changes to the staging area
  git add .

  # Commit changes
  git commit -m "Update Homebrew formula to version $PREVIOUS_VERSION"
  git remote set-url origin https://${GITHUB_USER_NAME}:${GITHUB_TOKEN}@github.com/veracode/${HOMEBREW_REPO}.git

  # Push the new branch to GitHub
  git push -u origin "$NEW_BRANCH"

  # Create a Pull Request using GitHub CLI (gh)
  # Install GitHub CLI (https://cli.github.com/) if you haven't already
  echo ${GITHUB_TOKEN} | gh auth login --with-token
  gh pr create --title "$PR_TITLE" --body "$PR_BODY" --head "$NEW_BRANCH" --repo "$REPO_URL"

  echo "Pull request created successfully."
else
  echo "No changes detected, skipping branch creation and PR."
fi

# Get the pull request ID
PR_ID=$(gh pr view --json number --jq '.number')
echo "PR ID $PR_ID"

# Check the status of PR checks
attempts=10
delay=60

for ((i=1; i<=attempts; i++))
do
  # Get the raw output of PR checks
  PR_CHECKS=$(gh pr checks $PR_ID)
  
  echo "Attempt $i: PR checks output:"
  echo "$PR_CHECKS"

  # Check for successful status
  if echo "$PR_CHECKS" | grep -q "pass"; then
    # Merge the pull request
    echo "CI Verification passed successfully"
    gh pr merge $PR_ID --merge
    echo "Pull request is merged successfully"
    break
  elif [[ $i -eq $attempts ]]; then
    echo "PR checks failed or not completed within the expected time."
    exit 1
  else
    echo "PR checks not yet completed, retrying in $delay seconds... (Attempt $i of $attempts)"
    sleep $delay
  fi
done

# Clean up
git config --global --unset-all user.name
git config --global --unset-all user.email
rm -rf ../../${HOMEBREW_REPO}








# Check if veracode-cli.rb already exists
if [[ -f "$UPDATED_FORMULA_PATH" ]]; then
  # Extract the existing version from the formula
  EXISTING_VERSION=$(awk 'NR==4 {print $2}' "$UPDATED_FORMULA_PATH" | tr -d '"')

  # Rename the existing formula file
  mv "$UPDATED_FORMULA_PATH" "$FORMULA_PATH/veracode-cli@${EXISTING_VERSION}.rb"
fi

# Update the formula for the new version
update_formula "$VERSION"

# List and sort veracode-cli files by version
VERACODE_FILES=($(ls "$FORMULA_PATH/veracode-cli@"* | sort -V))

# Count the number of versioned files
FILE_COUNT=${#VERACODE_FILES[@]}

# Keep only the 5 most recent versions by removing the oldest
if [[ $FILE_COUNT -gt 5 ]]; then
  FILES_TO_REMOVE=$((FILE_COUNT - 5))
  for ((i=0; i<$FILES_TO_REMOVE; i++)); do
    rm -f "${VERACODE_FILES[$i]}"
  done
fi

# Function to commit and push changes to GitHub
push_changes_to_github() {
  local branch_name=$1

  # Configure Git
  git config --global user.email "razauddin99@gmail.com"
  git config --global user.name "$GITHUB_USER"

  # Create a new branch
  git checkout -b "$branch_name"

  # Add changes to git
  git add "$FORMULA_PATH"

  # Commit the changes
  git commit -m "Update Homebrew formula to version $VERSION"

  # Push the branch to GitHub
  git push -u origin "$branch_name"
}

# Function to create a pull request on GitHub
create_pull_request() {
  local branch_name=$1

  # Create a pull request on GitHub
  local response=$(curl -s -u "$GITHUB_USER:$GITHUB_API_TOKEN" -X POST \
    -d "{\"title\":\"Update Homebrew formula to version $VERSION\",\"head\":\"$branch_name\",\"base\":\"main\"}" \
    "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/pulls")

  echo "$response" | jq -r '.url'
}

# Function to monitor the pull request status
monitor_pull_request() {
  local pr_url=$1

  while true; do
    sleep 60  # Check every minute
    local status=$(curl -s -u "$GITHUB_USER:$GITHUB_API_TOKEN" "$pr_url" | jq -r '.mergeable_state')
    if [[ "$status" == "clean" ]]; then
      echo "Pull request is ready to be merged."
      break
    elif [[ "$status" == "dirty" ]]; then
      echo "Pull request cannot be merged automatically."
      exit 1
    else
      echo "Pull request status: $status. Checking again in 1 minute."
    fi
  done
}

# Function to merge the pull request
merge_pull_request() {
  local pr_url=$1

  curl -s -u "$GITHUB_USER:$GITHUB_API_TOKEN" -X PUT \
    -d "{\"commit_title\":\"Merging pull request for version $VERSION\",\"merge_method\":\"merge\"}" \
    "$pr_url/merge"
}

# Main script execution

# Push changes to GitHub and create a pull request
push_changes_to_github "$BRANCH_NAME"
PR_URL=$(create_pull_request "$BRANCH_NAME")

# Monitor the pull request status and merge if ready
monitor_pull_request "$PR_URL"
merge_pull_request "$PR_URL"

# Print completion message
echo "Homebrew tap formula updated, pull request merged successfully."
