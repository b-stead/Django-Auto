
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

