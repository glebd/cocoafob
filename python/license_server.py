# Configurable mini license server with bare-bones logging.
# See server.wsgi for deployment.

from flask import Flask
from flask import Response
from flask import request
import cocoafob
import sqlite3

app = Flask(__name__)

def generate_response(secret, user, email):
  if secret not in app.secrets:
    return Response(response='Error: Wrong secret.', status=503)
  
  if not user:
    return Response(response='Error: User is required.', status=400)
  
  if not email:
    return Response(response='Error: Email is required.', status=400)

  with open(app.private_key_path) as keyfile:
    return Response(response=cocoafob.make_license(keyfile.read(), app.product, user))
  
def log_response(secret, user, email, response):
  db = sqlite3.connect(app.db_path)
  cursor = db.cursor()
  cursor.execute('CREATE TABLE IF NOT EXISTS requests '
                 '(date DATETIME, secret TEXT, user TEXT, email TEXT, response TEXT)')
  cursor.execute('INSERT INTO requests VALUES (CURRENT_TIMESTAMP, ?, ?, ?, ?)',
                  [secret, user, email, response.response[0]])
  db.commit()

@app.route('/', methods=['GET'])
def return_key():
  secret = request.args.get('secret', '')
  user = request.args.get('user', '')
  email = request.args.get('email', '')
  response = generate_response(secret, user, email)
  log_response(secret, user, email, response)
  return response

if __name__ == '__main__':
  # In production, use WSGI and configure these via server.wsgi!
  app.secrets = ['donttellanybody']
  app.db_path = '../keys/requests.db'
  app.private_key_path = '../keys/privkey.pem'
  app.product = 'product'
  app.run(debug=True)
