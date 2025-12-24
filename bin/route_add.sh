#!/bin/bash

# ----- SETTINGS -----
# Path to connected.sh
TBL_SCRIPT="/Users/username/Library/Application Support/Tunnelblick/Configurations/NAME.tblk/Contents/Resources/connected.sh"
# --------------------

if [ -z "$1" ]; then
  echo "Error: Specify IP or network (for example: ./add_route.sh 1.2.3.0/24)"
  exit 1
fi

TARGET=$1

# 1. Determining the current utun interface
CURRENT_UTUN=$(ifconfig | grep utun | grep 1500 | cut -d : -f1 | tail -1)

if [ -z "$CURRENT_UTUN" ]; then
  echo "Error: Can't find active utun interface."
  exit 1
fi

echo "Attempting to add route $TARGET via $CURRENT_UTUN..."

# 2. Running the route add command and capturing the output (stdout and stderr)
OUTPUT=$(sudo route add -net "$TARGET" -interface "$CURRENT_UTUN" 2>&1)
EXIT_CODE=$?

echo "$OUTPUT"

# 3. Checking the result
if [[ "$OUTPUT" == *"File exists"* ]]; then
  echo "Warning: The route already exists in the system."
elif [ $EXIT_CODE -eq 0 ]; then
  echo "Info: Route successfully added to the system."

  # Checking if there is already such an entry in the file, just in case (to avoid duplicating lines)
  if grep -q "$TARGET" "$TBL_SCRIPT"; then
     echo "Warning: The entry is already in the file connected.sh."
  else
     # Adding a line to a file.
     # Important: we escape \$utun so that the variable name is written to the file, not its current value
     echo "route add -net $TARGET -interface \$utun" >> "$TBL_SCRIPT"
     echo "Info: Added to $TBL_SCRIPT"
  fi
else
  echo "Error: An error occurred while adding the route. The file has not been modified."
fi