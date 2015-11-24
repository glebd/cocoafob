# Configurable mini license server with bare-bones logging.
# See server.wsgi for deployment.
# Usage: http://your-server/license/generate/?secret=donttellanybody&user=John%20Doe&email=john@doe.com

from flask import Flask
from flask import Response
from flask import request
import cocoafob
import sqlite3

app = Flask(__name__)
app.enable_caching = True

def generate_response(cursor, secret, user, email):
  if secret not in app.secrets:
    return Response(response='Error: Wrong secret.', status=503)
  
  if not user:
    return Response(response='Error: User is required.', status=400)
  
  if not email:
    return Response(response='Error: Email is required.', status=400)

  # Try to fetch an existing key from the DB.
  key = None
  if app.enable_caching:
    cursor.execute('SELECT response FROM requests WHERE secret = ? AND user = ? AND email = ? ORDER BY date ASC LIMIT 1', [secret, user, email])
    key_row = cursor.fetchone()
    if key_row and len(key_row[0]) >= 60:  # Crude check whether the response is a key and not an error message.
      key = key_row[0].encode('utf-8')
  
  if not key:
    # Need to read the private key and generate the key ourselves.
    with open(app.private_key_path) as keyfile:
      key = cocoafob.make_license(keyfile.read(), app.product, user)
  
  if key:
    return Response(response=key)
  else:
    return Response(response='Error: error generating the key.', status=500)
  
def log_response(cursor, secret, user, email, response):
  cursor.execute('CREATE TABLE IF NOT EXISTS requests '
                 '(date DATETIME, secret TEXT, user TEXT, email TEXT, response TEXT)')
  cursor.execute('INSERT INTO requests VALUES (CURRENT_TIMESTAMP, ?, ?, ?, ?)',
                  [secret, user, email, response.response[0]])

@app.route('/', methods=['GET'])
def return_key():
  secret = request.args.get('secret', '')
  user = request.args.get('user', '')
  email = request.args.get('email', '')
  db = sqlite3.connect(app.db_path)
  cursor = db.cursor()
  response = generate_response(cursor, secret, user, email)
  log_response(cursor, secret, user, email, response)
  db.commit()
  return response

if __name__ == '__main__':
  # In production, use WSGI and configure these via server.wsgi!
  app.secrets = ['donttellanybody']
  app.db_path = '../keys/requests.db'
  app.private_key_path = '../keys/privkey.pem'
  app.product = 'product'
  app.run(debug=True)
