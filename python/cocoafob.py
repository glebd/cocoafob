import base64
from OpenSSL import crypto # requires at least version 0.15.2 (or the latest version from GitHub, as this one is not yet released as of 2015/11/11)

# Creates a source string to generate the registration code with.
# A source string the contains product code name and the user's registration name,
# separated by a comma.
def make_license_source(product_code, name):
  return product_code + ',' + name

# This method generates a registration code. It receives your private key,
# a product code string and a registration name.
def make_license(private_key_string, product_code, name):
  private_key = crypto.load_privatekey(crypto.FILETYPE_PEM, private_key_string)
  signature = crypto.sign(private_key, make_license_source(product_code, name), 'sha1')
  # Use sha1 instead of dss1 to avoid 'ValueError("No such digest method")'
  encoded_signature = base64.b32encode(signature)
  # Replace 'O' with 8, 'I' with 9
  # See http://members.shaw.ca/akochoi-old/blog/2004/11-07/index.html
  encoded_signature = encoded_signature.replace('O', '8').replace('I', '9')
  # Remove equal signs
  encoded_signature = encoded_signature.replace('=', '')
  # Insert a dash every 5 characters
  encoded_signature = '-'.join([encoded_signature[i:i+5] for i in range(0, len(encoded_signature), 5)])
  return encoded_signature
 
def verify_license(public_key_string, encoded_signature, product_code, name):
  base32_signature = encoded_signature.replace('8', 'O').replace('9', 'I').replace('-', '')
  base32_signature += '=' * (8 - (len(base32_signature) % 8))
  decoded_signature = base64.b32decode(base32_signature)
  public_key = crypto.load_publickey(crypto.FILETYPE_PEM, public_key_string)
  certificate = crypto.X509()
  certificate.set_pubkey(public_key)
  try:
    crypto.verify(certificate, decoded_signature, make_license_source(product_code, name), 'sha1')
    # Use sha1 instead of dss1 to avoid 'ValueError("No such digest method")'
    return True
  except:
    return False

def main():
  with open('../keys/privkey.pem') as keyfile:
    private_key_string = keyfile.read()
  with open('../keys/pubkey.pem') as keyfile:
    public_key_string = keyfile.read()
  
  # test generation
  license = make_license(private_key_string, 'product', 'user')
  print 'license is ' + license
  
  # test verification
  assert(verify_license(public_key_string, license, 'product', 'user'))  # This throws on an invalid license
  print 'verification successful'

  # test rejection of invalid signature
  assert(not verify_license(public_key_string, license, 'product', 'WRONGUSER'))
  print 'rejection successful'

if __name__ == '__main__':
  main()
