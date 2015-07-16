//
//  main.swift
//  cocoafob-keygen
//
//  Created by Gleb Dolgich on 14/07/2015.
//  Copyright © 2015 PixelEspresso. All rights reserved.
//

import Foundation

let pubKey = StringOption(longFlag: "pubkey", helpMessage: "Public DSA key file path to verify registration")
let pvtKey = StringOption(longFlag: "pvtkey", helpMessage: "Private DSA key file path to generate registration")
let userName = StringOption(shortFlag: "u", longFlag: "username", helpMessage: "User name")
let regKey = StringOption(shortFlag: "r", longFlag: "regkey", helpMessage: "Registration key to verify")
let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Print help message")

let cli = CommandLine()
cli.addOptions(pubKey, pvtKey, userName, regKey, help)

var errStream = Stderr()

do {
  try cli.parse()
} catch {
  cli.printUsage(error)
  exit(EX_USAGE)
}

if let pub = pubKey.value {
  
  if let user = userName.value, let reg = regKey.value {
    do {
      if try verifyRegKey(pub, userName: user, regKey: reg) {
        print("Registration is valid")
      } else {
        print("Registration is invalid")
        exit(1)
      }
    } catch {
      print("ERROR: Unable to verify registration key -- \(error)", &errStream)
      exit(EX_DATAERR)
    }
  } else {
    print("ERROR: Specifying a public key means 'verify' and requires both user name and registration key", &errStream)
    cli.printUsage()
    exit(EX_USAGE)
  }
  
} else if let pvt = pvtKey.value {
  
  if let user = userName.value {
    if regKey.value != nil {
      print("WARNING: Specifying a private key means 'generate' and doesn't need a registration key", &errStream)
    }
    do {
      let reg = try generateRegKey(pvt, userName: user)
      print(reg)
    } catch {
      print("ERROR: Unable to generate registration key -- \(error)", &errStream)
      exit(EX_DATAERR)
    }
  } else {
    print("ERROR: Specifying a private key means 'verify' and requires a user name", &errStream)
    cli.printUsage()
    exit(EX_USAGE)
  }
  
} else {

  if help.value {
    cli.printUsage()
  } else {
    print("ERROR: Either private or public key must be provided", &errStream)
    cli.printUsage()
    exit(EX_USAGE)
  }

}
