cd Formula
# check how many formula files exists in the formula directory
VERACODE_FILES=($(ls veracode-cli@*))
FILE_COUNT=${#VERACODE_FILES[@]}

if [[ $FILE_COUNT -gt 4 ]]; then
  FILES_TO_REMOVE=$((FILE_COUNT - 4))
  for ((i=0; i<$FILES_TO_REMOVE; i++)); do
      echo "Removing ${VERACODE_FILES[$i]}"
      rm -rf "${VERACODE_FILES[$i]}"
  done
fi