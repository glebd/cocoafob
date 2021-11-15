/*
 * StringExtensions.swift
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

/* Required for localeconv(3) */
#if os(OSX)
import Darwin
#elseif os(Linux)
import Glibc
#endif

internal extension String {
    /* Retrieves locale-specified decimal separator from the environment
     * using localeconv(3).
     */
    private func _localDecimalPoint() -> Character {
        guard let locale = localeconv(), let decimalPoint = locale.pointee.decimal_point else {
            return "."
        }

        return Character(UnicodeScalar(UInt8(bitPattern: decimalPoint.pointee)))
    }

    /**
     * Attempts to parse the string value into a Double.
     *
     * - returns: A Double if the string can be parsed, nil otherwise.
     */
    func toDouble() -> Double? {
        let decimalPoint = String(self._localDecimalPoint())
        guard decimalPoint == "." || self.range(of: ".") == nil else { return nil }
        let localeSelf = self.replacingOccurrences(of: decimalPoint, with: ".")
        return Double(localeSelf)
    }

    /**
     * Pads a string to the specified width.
     *
     * - parameter toWidth: The width to pad the string to.
     * - parameter by: The character to use for padding.
     *
     * - returns: A new string, padded to the given width.
     */
    func padded(toWidth width: Int, with padChar: Character = " ") -> String {
        var s = self

        while s.count < width {
            s.append(padChar)
        }

        return s
    }
}
