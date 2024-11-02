# Django/Tailwind Project Setup with Automated Configuration

This repository contains a Django project setup with automated configuration scripts for project initialization, settings modularization, and dependency management. The folder structure and scripts help streamline the creation and management of Django projects with custom settings and Tailwind CSS integration.

## Requirements

- **Python 3.12+**
- **Node.js & npm** (for Tailwind CSS)
- **Django**, **ruff**, **logfire**, **python-dotenv** (automatically installed by script)

## Installation

1. Clone this repository and navigate into the folder:

   ```bash
   git clone https://github.com/b-stead/Django-Auto.git
   cd Django-Auto

2. Make sure both scripts are executable:
chmod +x setup_django_project.sh setup_django_settings.sh

3. Create Python VENV

4. Activate VENV

5. Run the setup script to create a new Django project.
./setup_django_project.sh <project_name>

Replace <project_name> with your desired project name.

## Scripts

setup_django_project.sh

The main script that:

Installs Django, ruff, logfire, and python-dotenv.
Initializes a Django project within the SRC/ directory.
Sets up Tailwind CSS for front-end styling.
Configures .gitignore and .env files with common entries.
Calls setup_django_settings.sh to set up a modular settings structure.

## Usage:
./setup_django_project.sh <project_name>

setup_django_settings.sh
This script modularizes Django settings by creating:

A settings folder inside the Django project directory (replaces the settings.py file).
base.py for shared settings across environments.
local_dev.py, staging.py, and prod.py for environment-specific settings.
Configures Django to load settings based on the DJANGO_ENV environment variable (local_dev, staging, or production).
Usage:

This script is automatically called by setup_django_project.sh, but you can also run it separately if needed:


## Tailwind CSS Usage

The setup includes Tailwind CSS for styling. To run Tailwind in development mode:
npm run dev


This command watches for changes in the Tailwind source files and outputs CSS to the appropriate directory.

## Configuration and Customization

Environment Variables: 

Place your environment-specific variables (e.g., SECRET_KEY, DATABASE_URL) in the .env file or export them directly in your shell session.

DJANGO_ENV: Set this variable to local_dev, staging, or production to control which settings are loaded.

Additional Apps: 
Add any additional Django apps to the INSTALLED_APPS list in settings/includes/base.py.

## Troubleshooting

BASE_DIR Issues: 

If BASE_DIR is not set correctly, check its definition in settings/includes/base.py. It should be targeting the project root where manage.py is located.

## Package Issues: 
If required packages aren’t installing, ensure your virtual environment is activated and pip is updated.

## License

This project is open-source and available under the MIT License.


--- 

This `README.md` provides detailed instructions for setting up and using the Django project, including explanations of each script and folder structure, making it easy to understand and customize.
