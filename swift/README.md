# CocoaFob Swift 2.0 Port

## Instructions

Add the necessary files directly to your project. For your app they are:

* `CocoaFob/CFUtil.swift`
* `CocoaFob/CocoaFobError.swift`
* `CocoaFob/CocoaFobLicVerifier.swift`
* `CocoaFob/CocoaFobStringExt.swift`

Generate your DSA key as described in the main README and add the public key as a resource to your app.

Look at the tests in `CocoaFobTests/CocoaFobTests.swift` to see how to verify a registration key.

## Dependencies

* CommandLine by Ben Gollmer, GitHub -- https://github.com/jatoben/CommandLine

```bash
git subtree add --squash --prefix vendor/CommandLine git://github.com/jatoben/CommandLine.git master
```
