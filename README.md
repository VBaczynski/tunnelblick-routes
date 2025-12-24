# Tunnelblick Route Sync Scripts

A set of Bash scripts to efficiently manage routing rules for [Tunnelblick](https://tunnelblick.net/) on macOS.

These scripts solve the synchronization problem: they apply route changes immediately to the current system session (via `route`) and automatically update the `connected.sh` Tunnelblick configuration file. This ensures that your custom routes persist after a VPN restart.

## Features

1.  **Smart Add (`route-add.sh`):**
    * Adds a route to the current system routing table.
    * If the route already exists in the system (error: `File exists`), it **does not** duplicate the entry in the configuration file.
    * If the route is successfully added, it appends the command to `connected.sh`.

2.  **Safe Delete (`route-del.sh`):**
    * Removes a route from the current system.
    * If the route is not in the routing table (error: `not in table`), it **does not** touch the configuration file.
    * It removes the line from `connected.sh` only if the route was successfully removed from the system.

## Prerequisites

* macOS
* [Tunnelblick](https://tunnelblick.net/) installed
* A VPN configuration with a `connected.sh` script enabled.

For more information on how Tunnelblick handles scripts, please refer to the [official documentation](https://tunnelblick.net/cUsingScripts.html).

## Setup & Installation

### 1. Prepare Tunnelblick
Add to your `.tblk` configuration package a `connected.sh` file.
The typical path is:
`~/Library/Application Support/Tunnelblick/Configurations/NAME.tblk/Contents/Resources/connected.sh`

A basic `connected.sh` should look like this:

```bash
#!/bin/bash
# Get the current utun interface name
utun=$(ifconfig | grep utun | grep 1500 | cut -d : -f1 | tail -1)

# Routes will be appended below by the scripts...
```

This file `connected.sh` must have execute permissions:

```bash
sudo chmod u+x ~/Library/Application\ Support/Tunnelblick/Configurations/NAME.tblk/Contents/Resources/connected.sh
```

### 2. Install Scripts
Download or copy route-add.sh and route-del.sh to a directory in your path (e.g., ~/bin).

Open both files in a text editor and update the TBL_SCRIPT variable with the absolute path to your connected.sh:

```bash
TBL_SCRIPT="/Users/YOUR_USER/Library/Application Support/Tunnelblick/Configurations/YOUR_VPN.tblk/Contents/Resources/connected.sh"
```

Make the scripts executable:

```bash
chmod +x ~/bin/route-add.sh
chmod +x ~/bin/route-del.sh
```

### 3. Shell Configuration (csh / tcsh)
If you are using csh or tcsh and placed the scripts in ~/bin, ensure this directory is in your $PATH so you can run them by name.

Add the following line to your ~/.cshrc:

```bash
set path = ($path ~/bin)
```

Apply the changes:

```bash
source ~/.cshrc
```

## Usage
Since `route add` and `route delete` require root privileges, the scripts will ask for your password (sudo).

Add a Route (Host or Network)
This adds the route to the system and saves it to connected.sh.

```bash
# Add a single host
route-add.sh 213.174.152.101/32
# or
sudo route-add.sh 213.174.152.101/32

# Add a network
route-add.sh 192.168.10.0/24
# or
sudo route-add.sh 192.168.10.0/24
```

Remove a Route

This removes the route from the system and deletes the corresponding line from connected.sh.

```bash
route-del.sh 213.174.152.101/32
# or
sudo route-del.sh 213.174.152.101/32
```

## Note on Variable Expansion
When route-add.sh writes to the file, it escapes the interface variable (writing \$utun instead of utun4). This ensures that when Tunnelblick runs the script upon reconnection, it uses the current interface name dynamically assigned by the system, preventing errors if the interface number changes.