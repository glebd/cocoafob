# CocoaFob Swift 5.0 Port

For a Swift 4-based version, see https://github.com/glebd/cocoafob/tree/master/swift4

## Instructions

Add the necessary files directly to your project. For your app they are:

* `CocoaFob/CFUtil.swift`
* `CocoaFob/CocoaFobError.swift`
* `CocoaFob/CocoaFobLicVerifier.swift`
* `CocoaFob/CocoaFobStringExt.swift`

Generate your DSA key as described in the main README and add the public key as a resource to your app.

Look at the tests in `CocoaFobTests/CocoaFobTests.swift` to see how to verify a registration key.

## Build

To build and install the `cocoafob-keygen` command-line utility for generating and verifying registration keys, execute the following command in the `swift` subdirectory of the CocoaFob project:

```bash
xcodebuild -target cocoafob-keygen install
```

The utility will be installed in `/usr/local/bin`.

## Dependencies

* CommandLine by Ben Gollmer, GitHub -- https://github.com/jatoben/CommandLine

```bash
git subtree {add|pull} --squash --prefix swift/vendor/CommandLine git://github.com/jatoben/CommandLine.git master
```
