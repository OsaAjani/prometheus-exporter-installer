#!/bin/bash

# Default values
exporter_name=""
dir_path=""
port=""
nginx_reverse=""
http_user=""
http_password=""
http_domain=""

# Function to display usage information
usage() {
    echo -e "Usage: $0 --exporter_name <exporter_name> --dir_path <directory_path> --port <exporter_port> [--nginx-reverse --http-user <http_user> --http-password <http_password> --http-domain <http_domain>]"
    exit 1
}


# Function to replace flags in conf files
replace_flags() {
    local file=$1
    sed -i "s/{{PORT}}/${port}/g" "$file"
    sed -i "s/{{EXPORTER_NAME}}/${exporter_name}/g" "$file"
    sed -i "s/{{HTTP_USER}}/${http_user}/g" "$file"
    sed -i "s/{{HTTP_PASSWORD}}/${http_password}/g" "$file"
    sed -i "s/{{HTTP_DOMAIN}}/${http_domain}/g" "$file"
}

# Parse the named parameters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --exporter_name) exporter_name="$2"; shift ;;
        --dir_path) dir_path="$2"; shift ;;
        --port) port="$2"; shift ;;
        --nginx-reverse) nginx_reverse="true" ;;  # Set a flag if --nginx-reverse is present
        --http-user) http_user="$2"; shift ;;
        --http-password) http_password="$2"; shift ;;
        --http-domain) http_domain="$2"; shift ;;
        *) echo -e "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Check if both parameters are provided
if [ -z "$exporter_name" ] || [ -z "$dir_path" ] || [ -z "$port" ]; then
    echo -e "Error: --exporter_name, --dir_path and --port are required."
    usage
fi

# Check if the directory exists
if [ ! -d "$dir_path" ]; then
    echo -e "Directory '$dir_path' does not exist."
    exit 1
fi



# Create dirs and users
echo -e "Create a exporter users and directories"
sudo groupadd -f "$exporter_name"
sudo useradd -g "$exporter_name" --no-create-home --shell /bin/false "$exporter_name"
sudo mkdir /etc/"$exporter_name"
sudo chown "$exporter_name":"$exporter_name" /etc/"$exporter_name"
echo -e "Done.\n\n"

# Copy binary
echo -e "Copy binary of exporter"
sudo cp "$dir_path/$exporter_name" /usr/bin/
sudo chown "$exporter_name:$exporter_name" "/usr/bin/$exporter_name"
echo -e "Done.\n\n"

# Create empty conf file
echo -e "Create empty exporter conf file, remember to fill it later !"
sudo touch "/etc/$exporter_name/$exporter_name.yml"
sudo chown "$exporter_name:$exporter_name" "/etc/$exporter_name/$exporter_name.yml"
echo -e "Done.\n\n"

# Create basic service file
echo -e "Create an default empty service arguments, remember to fill it later !"
sudo cp "./templates/systemd-args" "/etc/default/$exporter_name"
replace_flags "/etc/default/$exporter_name"
echo -e "Done.\n\n"

# Create the systemd service
echo -e "Create systemd service for exporter"
sudo cp "./templates/systemd.service" "/etc/systemd/system/$exporter_name.service"
replace_flags "/etc/systemd/system/$exporter_name.service"
echo -e "Done.\n\n"

# Reload systemd services and enable
echo -e "Reload systemd services and enable the exporter service"
sudo systemctl daemon-reload
sudo systemctl enable "$exporter_name.service"
echo -e "Done.\n\n"

# If needed add a secure nginx reverse proxy conf with auth
if [ "$nginx_reverse" == "true" ]; then
    echo -e "Add some Nginx secure reverse proxy for this exporter, with authentication process based on htaccess."
    printf "$http_user:$(openssl passwd -5 $http_password)\n" >> "/etc/$exporter_name/.htpasswd"

    sudo cp "./templates/nginx-site.conf" "/etc/nginx/sites-available/$http_domain.conf"
    replace_flags "/etc/nginx/sites-available/$http_domain.conf"
    sudo ln -s "/etc/nginx/sites-available/$http_domain.conf" "/etc/nginx/sites-enabled"

    sudo systemctl reload nginx.service
    echo -e "Done.\n\n"
fi
