# Debian Postinstall Setup

A comprehensive post-installation setup utility for Debian-based systems that automates various configuration tasks after a fresh Debian installation.

## Overview

This tool automates the setup of a Debian-based system with the following features:
- Essential package installation
- User configuration and permissions
- SSH server configuration and key management
- SMB/CIFS share discovery and mounting
- Automatic security updates

## Components

- `start.sh`: Bash script that installs prerequisites and launches the main setup utility
- `base.py`: Python script that provides the main post-installation configuration functionality

## Features

### Package Management
- Installs essential packages automatically
- Provides an interactive menu for optional package selection
- Supports Docker installation with fallback to docker.io if needed
- Installs specialized tools like 1Password CLI, Bitwarden CLI, and NVM

### User Management
- Configures sudo access for non-root users
- Sets up proper user permissions for Docker and other services
- Handles user group membership for enhanced security

### SSH Configuration
- Secures SSH server with best practices
- Generates SSH keys for the user
- Sets up authorized_keys for remote access
- Restricts SSH access by user for enhanced security

### Network Share Management
- Discovers SMB/CIFS shares on the local network
- Provides interactive selection of shares to mount
- Automatically configures fstab entries for persistent mounts
- Supports both anonymous and authenticated access

### Security
- Configures automatic security updates
- Sets up unattended-upgrades for critical security patches
- Applies security best practices for user management

## Usage

1. Run the start script to install prerequisites:
   ```
   ./start.sh
   ```

2. The script will check if it's running with sufficient privileges and if needed, will request elevation

3. The Python utility will guide you through the configuration process with interactive prompts

## LXC Container Support

The tool detects if it's running in an LXC container environment and adjusts its behavior accordingly:
- Uses root for all operations in LXC
- Adjusts SSH configuration for container use
- Modifies user management for container environments

## Requirements

- Debian-based Linux distribution
- Python 3.x
- Internet connection for package installation
- Root access (will request elevation if needed)

## Logging

The tool maintains a detailed log at `base.log` that can be used for troubleshooting.

## License

This project is licensed under the MIT License.
