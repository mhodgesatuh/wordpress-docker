# WordPress Docker Stack

A fully non-interactive Docker Compose setup for WordPress with MariaDB and phpMyAdmin.

<!-- TOC -->
* [WordPress Docker Stack](#wordpress-docker-stack)
  * [Quick Start (Non-Interactive)](#quick-start-non-interactive)
    * [Prerequisites](#prerequisites)
    * [Deployment Steps](#deployment-steps)
  * [Access the Services](#access-the-services)
  * [Architecture](#architecture)
    * [Services](#services)
    * [Data Persistence](#data-persistence)
    * [Networks](#networks)
  * [How Non-Interactive Installation Works](#how-non-interactive-installation-works)
  * [Stopping and Restarting](#stopping-and-restarting)
  * [Troubleshooting](#troubleshooting)
    * [Check logs](#check-logs)
    * [Database connection issues](#database-connection-issues)
    * [Reset the Database](#reset-the-database)
<!-- TOC -->

## Quick Start (Non-Interactive)

### Prerequisites
- Docker and Docker Compose installed.
- A `.env` file with the required environment variables.

### Deployment Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mhodgesatuh/wordpress-docker.git
   cd wordpress-docker
   ```

2. **Configure environment variables:**
   Copy the `.env.example` file to `.env` and provide the required values.
   ```bash
   cp .env.example .env
   ```

3. **Start the stack non-interactively:**
   ```bash
   ./build.sh
   ```
   
   Or, use Docker Compose directly:
   ```bash
   docker compose up -d
   ```

4. **Wait for initialization:**
   The WordPress installation happens automatically. You can check the logs:
   ```bash
   docker compose logs -f wordpress
   ```

## Access the Services

- **WordPress:** http://localhost:8080
  - Admin URL: http://localhost:8080/wp-admin

- **phpMyAdmin:** http://localhost:8081

## Architecture

### Services
- **db** - MariaDB 10.5 database server
- **wordpress** - WordPress with Apache and WP-CLI
- **phpmyadmin** - phpMyAdmin for database management

### Data Persistence
- Database data is stored in a named Docker volume: `db_data`
- WordPress files are stored in an anonymous volume: `/usr/src/wordpress`

### Networks
All services communicate via the `wp-network` Docker bridge network.

## How Non-Interactive Installation Works

1. **`build.sh`** - Non-interactive startup script that:
   - Reads environment variables from `.env` file
   - Validates all required variables are present
   - Starts Docker Compose services

2. **`init.sh`** - Automatic WordPress initialization that:
   - Waits for the database to be ready (with timeout)
   - Validates environment variables
   - Creates `wp-config.php` (if not exists)
   - Installs WordPress core (if not installed)
   - Installs and activates classic-editor plugin
   - Starts Apache server
   - Includes detailed logging with timestamps

## Stopping and Restarting

```bash
# Stop services
docker compose down

# Stop services and remove volumes (WARNING: deletes database!)
docker compose down -v

# Restart services
docker compose up -d
```

## Troubleshooting

### Check logs
```bash
# All services
docker compose logs

# Specific service
docker compose logs wordpress
docker compose logs db
docker compose logs phpmyadmin
```

### Database connection issues
The `init.sh` script will retry up to 60 times (5 minutes) to connect to the database.

### Reset the Database

You have multiple options to reset the database and start fresh:

**Option 1: Using the convenience script (Recommended)**
```bash
./reset-db.sh
```
This script will:
- Prompt for confirmation
- Stop all services
- Delete the database volume
- Restart services with a fresh database
- Preserve your `.env` credentials

**Option 2: Manual reset**
```bash
docker compose down -v
docker compose up -d
```
The `-v` flag removes all volumes including the database.

**Option 3: Keep WordPress files, reset only database**
```bash
docker volume rm wordpress-docker_db_data
docker compose up -d
```
