#!/bin/bash

# Check if project name is provided
if [ -z "$1" ]; then
  echo "Please provide a project name."
  echo "Usage: bash setup_django_settings.sh <project_name>"
  exit 1
fi

PROJECT_NAME=$1
PROJECT_DIR="SRC/$PROJECT_NAME"
INNER_PROJECT_DIR="${PROJECT_DIR}/${PROJECT_NAME}"  # Inner project directory where manage.py is located

# Define paths for settings
SETTINGS_DIR="${INNER_PROJECT_DIR}/settings"  # Place settings inside the inner project directory
INCLUDES_DIR="${SETTINGS_DIR}/includes"
mkdir -p $INCLUDES_DIR

# Move the original settings.py to base.py in includes folder
mv "${INNER_PROJECT_DIR}/settings.py" "${INCLUDES_DIR}/base.py"

# Create base.py for common settings
BASE_SETTINGS="${INCLUDES_DIR}/base.py"
echo "
import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Paths
BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent

# Security and Debugging
SECRET_KEY = os.getenv('SECRET_KEY', 'replace-me-for-production')
DEBUG = False  # Default to False for all environments; overridden in local_dev.py

ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '127.0.0.1').split(',')

# Applications
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'core',
]

# Middleware
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# URL Configuration
ROOT_URLCONF = '${PROJECT_NAME}.urls'

# Templates
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# Database - Placeholder for environment-specific configuration
DATABASES = {}

# Static files
STATIC_URL = '/static/'
STATICFILES_DIRS = [BASE_DIR / 'static']

# Custom User Model
AUTH_USER_MODEL = 'core.CustomUser'

# Logging configuration placeholder for environment-specific logging
LOGGING = {}
" > $BASE_SETTINGS

# Create environment-specific settings files (local_dev, staging, prod)
for ENV in local_dev staging prod; do
  ENV_SETTINGS="${SETTINGS_DIR}/${ENV}.py"
  echo "# ${ENV} settings

from .includes.base import *

# Environment-specific configurations

" > $ENV_SETTINGS
done

# Populate environment-specific files with necessary overrides

# local_dev.py
echo "
from .includes.base import BASE_DIR

DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'DEBUG',
    },
}
" > "${SETTINGS_DIR}/local_dev.py"

# staging.py
echo "
import os

DEBUG = False

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('STAGING_DB_NAME'),
        'USER': os.getenv('STAGING_DB_USER'),
        'PASSWORD': os.getenv('STAGING_DB_PASSWORD'),
        'HOST': os.getenv('STAGING_DB_HOST'),
        'PORT': os.getenv('STAGING_DB_PORT', '5432'),
    }
}

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
}
" > "${SETTINGS_DIR}/staging.py"

# prod.py
echo "
import os

DEBUG = False

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('PROD_DB_NAME'),
        'USER': os.getenv('PROD_DB_USER'),
        'PASSWORD': os.getenv('PROD_DB_PASSWORD'),
        'HOST': os.getenv('PROD_DB_HOST'),
        'PORT': os.getenv('PROD_DB_PORT', '5432'),
    }
}

SECURE_SSL_REDIRECT = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
        'logfire': {
            'level': 'ERROR',
            'class': 'logfire.DjangoHandler',
            'api_key': os.getenv('LOGFIRE_API_KEY'),
        },
    },
    'root': {
        'handlers': ['console', 'logfire'],
        'level': 'ERROR',
    },
}
" > "${SETTINGS_DIR}/prod.py"

# Update __init__.py in settings to load environment-specific settings dynamically
echo "
# settings/__init__.py

import os
from .includes.base import *

environment = os.getenv('DJANGO_ENV', 'local_dev')
if environment == 'production':
    from .prod import *
elif environment == 'staging':
    from .staging import *
else:
    from .local_dev import *
" > "${SETTINGS_DIR}/__init__.py"

# Inform the user to set DJANGO_ENV for different environments
echo "To use different environments, set the DJANGO_ENV environment variable to one of 'local_dev', 'staging', or 'production'."
