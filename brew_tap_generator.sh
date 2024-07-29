# Check if veracode-cli.rb already exists
if [[ -f veracode-cli.rb ]]; then
  version "2.28.0"
  EXISTING_VERSION=$(awk 'NR==4 {print $2}' veracode-cli.rb | tr -d '"')
  # Rename the existing formula file
  mv veracode-cli.rb "veracode-cli@${EXISTING_VERSION}.rb"
fi

# Copy the updated formula
cp -f ../../formula/updated_formula.rb veracode-cli.rb
