
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

