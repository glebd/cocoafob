#!/usr/bin/env ruby
#
# Modify this file and put in your own license key generator
#

require "openssl"
require "rubygems"
require "base32"

APPNAME = "the-archive"
PRIVKEY = "path/to/privkey.pem"
PUBKEY = "path/to/pubkey.pem"

# Creates a source string to generate registration code. A source string
# contains product code name and user's registration name.
def make_license_source(product_code, name)
  product_code + "," + name
end

# This method is called by Potion Store to generate a registration code. It
# receives a product code string, a registration name and quantity. I'm not
# using quantity here, but you're free to do it.
def make_license(product_code, name, copies)
  sign_dss1 = OpenSSL::Digest::SHA1.new
  priv = OpenSSL::PKey::DSA.new(File.read(PRIVKEY))
  b32 = Base32.encode(priv.sign(sign_dss1, make_license_source(product_code, name)))
  # Replace Os with 8s and Is with 9s
  # See http://members.shaw.ca/akochoi-old/blog/2004/11-07/index.html
  b32.gsub!(/O/, '8')
  b32.gsub!(/I/, '9')
  # chop off trailing padding
  b32.delete("=").scan(/.{1,5}/).join("-")
end

def verify_license(product_code, name, copies, lic)
  verify_dss1 = OpenSSL::Digest::SHA1.new
  pub = OpenSSL::PKey::DSA.new(File.read(PUBKEY))
  lic.delete!("-")
  lic.gsub!(/9/, 'I')
  lic.gsub!(/8/, 'O')
  # padded length has to divide by 8
  padded_length = lic.length%8 ? (lic.length/8 + 1)*8 : lic.length
  padded = lic + "=" * (padded_length-lic.length)
  pub.verify(verify_dss1, Base32.decode(padded), make_license_source(product_code, name))
end

if ARGV.empty?
  # Simple command line test when called without any arguments
  require "test/unit"
  class TestPxLic < Test::Unit::TestCase
    def test_make_license
      1000.times do
        lic = make_license(APPNAME, 'User Name', 10)
        puts lic
        assert verify_license(APPNAME, 'User Name', 10, lic), "Failed with #{lic}"
      end
    end
  end
else
  # Generate license when called with 1+ argument (assuming it's a name)
  name = ARGV.pop
  lic = make_license(APPNAME, name, 1)
  puts name
  puts lic
end
