# Exporter Setup Script

This script automates the setup of an exporter service on a Unix-like system. It handles the creation of necessary user accounts, directories, configuration files, and systemd service files, making it easier to deploy and manage exporters.

## Features

- Creates a dedicated user and group for the exporter.
- Sets up the necessary directories and permissions.
- Copies the exporter binary to the appropriate location.
- Generates an empty configuration file for the exporter.
- Creates a systemd service file for easy management.
- (Optional) Configures Nginx as a secure reverse proxy with basic authentication.

## Prerequisites

- Bash
- `sudo` privileges
- Nginx (if using the reverse proxy feature)
- OpenSSL (for password hashing)

## Usage

```bash
./setup_exporter.sh --exporter_name <exporter_name> --dir_path <directory_path> --port <exporter_port> [--nginx-reverse --http-user <http_user> --http-password <http_password> --http-domain <http_domain>]
```

### Parameters

- `--exporter_name`: The name of the exporter service (required).
- `--dir_path`: The directory path where the exporter binary is located (required).
- `--port`: The port on which the exporter will run (required).
- `--nginx-reverse`: Optional flag to set up an Nginx reverse proxy.
- `--http-user`: Username for Nginx basic authentication (required if `--nginx-reverse` is set).
- `--http-password`: Password for Nginx basic authentication (required if `--nginx-reverse` is set).
- `--http-domain`: The domain for the Nginx configuration (required if `--nginx-reverse` is set).

### Example

```bash
./setup_exporter.sh --exporter_name my_exporter --dir_path /path/to/exporter --port 8080 --nginx-reverse --http-user admin --http-password mysecurepassword --http-domain example.com
```

## Script Overview

1. **Usage Function**: Displays usage information if parameters are missing or invalid.
2. **Parameter Parsing**: Parses command-line arguments to set necessary variables.
3. **Directory Checks**: Validates the existence of the specified directory.
4. **User and Directory Creation**: Sets up a user group and a directory for the exporter.
5. **Binary Copy**: Copies the exporter binary to `/usr/bin/`.
6. **Configuration File**: Creates an empty configuration file for the exporter.
7. **Service File Creation**: Sets up a systemd service file for the exporter.
8. **Nginx Configuration (optional)**: If specified, configures Nginx with basic authentication for secure access.

## Notes

- Ensure that the `systemd-args` and `systemd.service` templates are correctly configured before running the script.
- After setup, remember to fill in the created configuration files with the appropriate settings.
- You may need to modify Nginx configurations based on your server setup.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
