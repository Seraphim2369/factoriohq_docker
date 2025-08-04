# FactorioHQ
This is a fork of FactorioHQ for docker deployment on the remote machine.
FactorioHQ is a web application for managing Factorio game servers using Docker containers. It provides a user-friendly interface to create, configure, and manage multiple Factorio servers.

## Features

- Create and manage multiple Factorio servers
- Configure server settings (port, password, max players, etc.)
- Start, stop and update servers with a single click
- Upload and manage save files
- View server and game logs in real-time
- Manage server mods
- Uses the [factoriotools](https://hub.docker.com/r/factoriotools/factorio/) Docker image to run game servers

#### Manage Multiple Servers
![Manage Multiple Servers](screenshots/factoriohq-servers.png)

#### Configure Server Settings
![Configure Server Settings](screenshots/factoriohq-server-details.png)

#### Manage Mods
![Manage Mods](screenshots/factoriohq-mods.png)

## Requirements

- Ruby 3.2.4
- Rails 8.0.2
- Docker

## Installation

⚠️ WARNING ⚠️ Server must run as 845:845 to match factoriotools docker image file permissions

1. Clone the repository
   ```bash
   git clone https://github.com/Seraphim2369/factoriohq_docker.git
   ```
2. Make a folder for server data and give permissions
   ```bash 
    sudo mkdir -p /factorio_data 
    sudo chowm 845:845 /factorio_data
   ```
3. Build containers
   ```bash
   cd factoriohq
   docker compose build
   ```

4. Start containers
   ```bash
   docker compose up -d
   ```
5. Access UI via browser
   ```bash 
    http:/<server ip adresss>:3000
   ```

## Usage

1. Register an account and log in (first user to register will be marked as an admin)
2. Create a new Factorio server
3. Configure server settings
4. Upload save files and/or mods (optional)
5. Start the server (the first time you start a server may take a few minutes to download the image)
6. Connect to the server using the Factorio game client

## Server Management

- **Start/Stop**: Control server state from the server details page
- **Update Version**: Update Factorio version seemlessly
- **Save Files**: Upload, download, and manage save files
- **Mods**: Browse, upload, download, and manage mods
- **Logs**: View server and game logs for troubleshooting

## Development

### Background Jobs

FactorioHQ uses background jobs for server operations and log streaming:

- `ServerOperationJob`: Handles starting and stopping servers
- `StreamGameLogsJob`: Captures and stores game logs
- `ServerStatusSyncJob`: Runs when web server starts to sync server status with actual Docker container status

## License

[MIT License](LICENSE)