# Overview

CocoaFob is a set of helper code snippets for registration code generation and
verification in Objective-C applications, integrated with registration code
generation in Potion Store <http://www.potionfactory.com/potionstore> and
FastSpring <http://fastspring.com>.

The current implementation uses DSA to generate registration keys, which
significantly reduces chances of crackers producing key generators for your
software. Unfortunately, it also means the registration code can be quite long
and has variable length.

To make registration codes human-readable, CocoaFob encodes them using a
slightly modified base32 to avoid ambiguous characters. It also groups codes in
sets of five characters separated by dashes. A sample registration code
produced using a 512-bit DSA key looks like this:

`GAWQE-FCUGU-7Z5JE-WEVRA-PSGEQ-Y25KX-9ZJQQ-GJTQC-CUAJL-ATBR9-WV887-8KAJM-QK7DT-EZHXJ-CR99C-A`

One of the advantages of DSA is that for a given registration name, each
generated code is different, as there is a random element introduced during the
process.

The name 'CocoaFob' is a combination of 'Cocoa' (the Mac and iOS programming
framework) and 'Fob' (a key fob is something you keep your keys on).

# Features

CocoaFob provides the following for your application:

- Secure asymmetric cryptography-based registration key generation and
  verification using DSA.

- Support for key generation in Objective-C and Ruby and verification in
  Objective-C for integration in both your Cocoa application and Potion Store.

- Support for custom URL scheme for automatic application registration.

There is no framework or a library to link against. You include the files you
need in your application project directly and are free to modify the code in
any way you need.

You may also find other snippets of code useful, such as base32 and base64
encoding/decoding functions, as well as categories extending `NSString` and
`NSData` classes with base32 and base64 methods.

# Usage

The best way to get the latest version of the code is to clone the main Git
repository:

`git://github.com/glebd/cocoafob.git`

You can also download the latest version from the CocoaFob home page at
<http://github.com/glebd/cocoafob/>.

For more complete examples of how to use CocoaFob, look at the following
projects by Alex Clarke: CodexFab <https://github.com/machinecodex/CodexFab/>
and LicenseExample <https://github.com/machinecodex/CodexFab_LicenseExample/>.

## Providing a Registration Source String

To register an application that uses CocoaFob, it is necessary to provide a
string of source information, which may be as simple as a registration name
or arbitrarily complex in case your application is processing the included
information in a user-friendly way. For example, as suggested in the sample
implementation of Potion Store licence generator, a source string may contain
application name, user name and number of copies:

`myapp|Joe Bloggs|1`

When sending registration mail, you need to provide both the source string and
the registration code. Potion Store does this for you. However, small
modifications are needed to make automatic activation work.

## Generating automatic activation URLs

Potion Store supports automatic activation of an installed application by
clicking on a special link in a registration email or on the Thank You store
page. For this to work, you need to:

- make your application support a registration URL scheme;

- modify Potion Store so that automatic activation link contains not only
  registration code, but registration source string as well.

The stock implementation of Potion Store registration code support assumes a
registration code is all that is needed to register an application. However,
CocoaFob needs to know both registration name and registration code in order
to verify the licence. This means when Potion Store generates an automatic
registration URL for your application, it needs to include registration source
string in it. One of the possible solutions is as follows:

- In your database migration `001_create_tables.rb`, increase the length of
  `license_key` column in `line_items` table to 128 characters:

```ruby
    t.column "license_key", :string, :limit => 128
```

- In the file `app/models/line_item.rb`, add the following line at the top:

```ruby
    require "base64"`
```

- In the same file find function called `license_url` near the bottom of the
  file. Replace it with the following (or modify to your heart's content):

```ruby
  def license_url
    licensee_name_b64 = Base64.encode64(self.order.licensee_name)
    return "#{self.product.license_url_scheme}://#{licensee_name_b64}/#{self.license_key}" rescue nil
  end
```

This will make generated registration codes to contain base64-encoded licensee
name. When your application is opened by clicking on the registration link, it
will parse the code, extract the registration name and use it to verify the
licence.

## Supporting registration URL schema in your app

The following files in objc directory provide a sample implementation of
support for custom URL schema for application registration. The code is almost
literally taken from [3].

To support registration URLs in your application:

- Add files `MyApp.scriptSuite` and `MyApp.scriptTerminology` to your project's
  resources, adjusting strings inside appropriately.

- Add the following to your application's `Info.plist` file under `/plist/dict`
  key (replace *mycompany* and *myapp* with strings appropriate for your company
  and application):

```xml
  <key>NSAppleScriptEnabled</key>
  <string>YES</string>
  <key>CFBundleURLTypes</key>
  <array>
      <dict>
          <key>CFBundleURLSchemes</key>
          <array>
              <string>com.mycompany.myapp.lic</string>
          </array>
      </dict>
  </array>
```

- Add the files `URLCommand.h` and `URLCommand.m` to your project, paying
  attention to the `TODO:` comments in them. Specifically, you may want to save
  registration information to your application's preferences, and also
  broadcast a notification of a changed registration information after
  verifying the supplied registration URL.

- Be sure the URL scheme name in the `Info.plist` file
  (`com.mycompany.myapp.lic`) is the same as the one in the database generation
  script for Potion Store. It is the file `db/migrate/001_create_tables.rb`,
  and the variable is called `license_url_scheme`.

Test the URL schema support by making a test purchase which results in
displaying an activation link, and clicking on it. If you are running your
application in debugger, place a breakpoint in the instance method
`performWithURL:` of the class `URLCommand`. The breakpoint will be triggered
when you click on the registration link. You can extract the link into a
standalone HTML file so that is available for testing without making any
additional test purchases.

# Generating Keys

IMPORTANT NOTE: Included keys are for demonstration and testing purposes only.
DO NOT USE THE INCLUDED KEYS IN YOUR SOFTWARE. Before incorporating CocoaFob
into your application, you need to generate a pair of your own DSA keys. I used
key length of 512 bit which I thought was enough for the registration code
generation purposes.

(0) Make sure OpenSSL is installed. (If you're using Mac OS X, it already is.)

(1) Generate DSA parameters:

    openssl dsaparam -out dsaparam.pem 512

(2) Generate an unencrypted DSA private key:

    openssl gendsa -out privkey.pem dsaparam.pem

(3) Extract public key from private key:

    openssl dsa -in privkey.pem -pubout -out pubkey.pem

See [2] for more information.

# Licence

CocoaFob is distributed under the BSD License
<http://www.opensource.org/licenses/bsd-license.php>. See the [LICENSE](LICENSE) file.

# Credits

[0] The Mac developer community that continues to amaze me.

[1] Base32 implementation is Copyright &copy; 2007 by Samuel Tesla and comes from
Ruby base32 gem: <http://rubyforge.org/projects/base32/>.

[2] OpenSSL key generation HOWTO: <http://www.openssl.org/docs/HOWTO/keys.txt>

[3] Handling URL schemes in Cocoa: a blog post by Kimbro Staken

[4] Registering a protocol handler for an App: a post on CocoaBuilder mailing
list

[5] PHP implementation courtesy of Sandro Noel

[6] Security framework-based implementation by Matt Stevens, <http://codeworkshop.net>

[7] New API by Danny Greg, <http://dannygreg.com>
