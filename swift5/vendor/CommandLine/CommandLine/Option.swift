/*
 * Option.swift
 * Copyright (c) 2014 Ben Gollmer.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * The base class for a command-line option.
 */
public class Option {
  public let shortFlag: String?
  public let longFlag: String?
  public let required: Bool
  public let helpMessage: String

  /** True if the option was set when parsing command-line arguments */
  public var wasSet: Bool {
    return false
  }

  public var claimedValues: Int { return 0 }

  public var flagDescription: String {
    switch (shortFlag, longFlag) {
    case let (sf?, lf?):
      return "\(shortOptionPrefix)\(sf), \(longOptionPrefix)\(lf)"
    case (nil, let lf?):
      return "\(longOptionPrefix)\(lf)"
    case (let sf?, nil):
      return "\(shortOptionPrefix)\(sf)"
    default:
      return ""
    }
  }

  internal init(_ shortFlag: String?, _ longFlag: String?, _ required: Bool, _ helpMessage: String) {
    if let sf = shortFlag {
      assert(sf.count == 1, "Short flag must be a single character")
      assert(Int(sf) == nil && sf.toDouble() == nil, "Short flag cannot be a numeric value")
    }

    if let lf = longFlag {
      assert(Int(lf) == nil && lf.toDouble() == nil, "Long flag cannot be a numeric value")
    }

    self.shortFlag = shortFlag
    self.longFlag = longFlag
    self.helpMessage = helpMessage
    self.required = required
  }

  /* The optional casts in these initalizers force them to call the private initializer. Without
   * the casts, they recursively call themselves.
   */

  /** Initializes a new Option that has both long and short flags. */
  public convenience init(shortFlag: String, longFlag: String, required: Bool = false, helpMessage: String) {
    self.init(shortFlag as String?, longFlag, required, helpMessage)
  }

  /** Initializes a new Option that has only a short flag. */
  public convenience init(shortFlag: String, required: Bool = false, helpMessage: String) {
    self.init(shortFlag as String?, nil, required, helpMessage)
  }

  /** Initializes a new Option that has only a long flag. */
  public convenience init(longFlag: String, required: Bool = false, helpMessage: String) {
    self.init(nil, longFlag as String?, required, helpMessage)
  }

  func flagMatch(_ flag: String) -> Bool {
    return flag == shortFlag || flag == longFlag
  }

  func setValue(_ values: [String]) -> Bool {
    return false
  }
}

/**
 * A boolean option. The presence of either the short or long flag will set the value to true;
 * absence of the flag(s) is equivalent to false.
 */
public class BoolOption: Option {
  private var _value: Bool = false

  public var value: Bool {
    return _value
  }

  override public var wasSet: Bool {
    return _value
  }

  override func setValue(_ values: [String]) -> Bool {
    _value = true
    return true
  }
}

/**  An option that accepts a string value. */
public class StringOption: Option {
  private var _value: String? = nil

  public var value: String? {
    return _value
  }

  override public var wasSet: Bool {
    return _value != nil
  }

  override public var claimedValues: Int {
    return _value != nil ? 1 : 0
  }

  override func setValue(_ values: [String]) -> Bool {
    if values.count == 0 {
      return false
    }

    _value = values[0]
    return true
  }
}
