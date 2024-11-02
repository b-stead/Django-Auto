#!/bin/bash

# Check if project name is provided
if [ -z "$1" ]; then
  echo "Please provide a project name."
  echo "Usage: bash setup_django_project.sh <project_name>"
  exit 1
fi

PROJECT_NAME=$1

# Step 2: Install Django and other required packages
python3 -m pip install --upgrade pip
pip install django python-dotenv ruff logfire[django]

# Step 3: Create project structure

# Step 9: Create .gitignore and .env
echo "
# Python files
__pycache__/
*.py[cod]
*.pyo

# Virtual Environment
venv/

# Django settings
SRC/$PROJECT_NAME/.env

# Node modules for Tailwind (if applicable)
node_modules/

# Static files
staticfiles/

# Database
db.sqlite3
" > .gitignore

mkdir -p SRC
cd SRC
django-admin startproject $PROJECT_NAME

# Step 4: Set up Tailwind CSS
npm install -D tailwindcss
npx tailwindcss init

echo "
# Django environment variables
DEBUG=True
SECRET_KEY='your-secret-key'
LOGFIRE_API_KEY='your-logfire-api-key'
" > $PROJECT_NAME/.env

# Step 5: Create Tailwind directories and files
mkdir -p $PROJECT_NAME/static/src $PROJECT_NAME/static/css
echo "@tailwind base; @tailwind components; @tailwind utilities;" > $PROJECT_NAME/static/src/main.css
touch $PROJECT_NAME/static/css/output.css

# update package.json
echo '{
  "devDependencies": {
    "tailwindcss": "^3.4.14"
  },
  "scripts": {
    "dev": "tailwindcss -i ./${PROJECT_NAME}/static/src/main.css -o ./${PROJECT_NAME}/static/css/output.css --watch"
  }
}' > package.json

# Step 3: Use sed to replace the placeholder ${PROJECT_NAME} with the actual project name
sed -i '' "s/\${PROJECT_NAME}/$PROJECT_NAME/g" package.json

# Step 8: Create ruff configuration file
echo "
[tool.ruff]
line-length = 120
indent-width = 4
target-version = "py312"
extend-exclude = ["migrations", "**/local_settings.py"]

[tool.ruff.lint]
select = ["E", "F", "W", "I", "S", "B"]
ignore = ["S608"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"
docstring-code-line-length = "dynamic"

[tool.ruff.lint.isort]
case-sensitive = true
" > ../pyproject.toml

# Step 10: Navigate to the project directory and apply migrations
cd $PROJECT_NAME

# Step 6: Start core app for custom user model and other logic
python manage.py startapp core

mkdir -p core/templates/core
touch core/templates/core/base.html

# update tailwind.config.js
cd ..

cat <<EOL > tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "${PROJECT_NAME}/core/templates/**/*.{html,js}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOL

# Step 7: Update project settings to a modular structure
# Call setup_django_settings.sh with the project name
cd ..
bash setup_django_settings.sh $PROJECT_NAME

# Step 9: Create Custom User model
cd SRC/$PROJECT_NAME

CUSTOM_USER_MODEL="
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)

class CustomUser(AbstractBaseUser):
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=30, blank=True)
    last_name = models.CharField(max_length=30, blank=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.email
"
echo "$CUSTOM_USER_MODEL" > core/models.py

# Migrate database
python manage.py makemigrations
python manage.py migrate

echo "Setup complete. To create a superuser, run: python manage.py createsuperuser"
