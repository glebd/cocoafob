# Sample server file for use with WSGI.
# The corresponding Apache config would be (taken from http://flask.pocoo.org/docs/0.10/deploying/mod_wsgi/):
#
#     WSGIDaemonProcess license_server user=timing group=timing threads=5
#     WSGIScriptAlias /license/generate /path/to/your/app/server.wsgi
#
#     <Directory /path/to/your/app>
#         WSGIProcessGroup license_server
#         WSGIApplicationGroup %{GLOBAL}
#         WSGIScriptReloading On
#         Require all granted
#     </Directory>

import sys
sys.path.insert(0, '/path/to/your/app')

from license_server import app as application

application.secrets = ['some-random-string']
application.db_path = '/path/to/your/app/requests.db'
application.private_key_path = '/path/to/your/app/privkey.pem'
application.product = 'product'

