#!/bin/bash

# ----- SETTINGS -----
# Path to connected.sh
TBL_SCRIPT="/Users/username/Library/Application Support/Tunnelblick/Configurations/NAME.tblk/Contents/Resources/connected.sh"
# --------------------

if [ -z "$1" ]; then
  echo "Error: Specify IP or network (for example: ./del_route.sh 1.2.3.0/24)"
  exit 1
fi

TARGET=$1

echo "Attempting to delete route $TARGET..."

# 1. Running the route delete command
OUTPUT=$(sudo route delete "$TARGET" 2>&1)
EXIT_CODE=$?

echo "$OUTPUT"

# 2. Processing logic
if [[ "$OUTPUT" == *"not in table"* ]]; then
  echo "Warning: The route is not in the table."
elif [ $EXIT_CODE -eq 0 ]; then
  echo "Route deleted from the system."

# 3. Deleting a line from a file (using sed)
  # -i '' is required for macOS version of sed to edit file "in place" without backup
  if grep -q "$TARGET" "$TBL_SCRIPT"; then
      sudo sed -i '' "/$TARGET/d" "$TBL_SCRIPT"
      echo "Info: The line with $TARGET removed from the connected.sh file."
  else
      echo "Warning: The route has been deleted from the system, but no such entry was found in the connected.sh file."
  fi
else
  echo "Error: Error deleting. The file connected.sh has not been modified."
fi