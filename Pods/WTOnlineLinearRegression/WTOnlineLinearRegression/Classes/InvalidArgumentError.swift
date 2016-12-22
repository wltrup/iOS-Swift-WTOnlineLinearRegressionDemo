/*
 InvalidArgumentError.swift
 WTOnlineLinearRegression

 Created by Wagner Truppel on 2016.12.07

 The MIT License (MIT)

 Copyright (c) 2016 Wagner Truppel.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

 When crediting me (Wagner Truppel) for this work, please use one
 of the following two suggested formats:

 Uses "WTOnlineLinearRegression" by Wagner Truppel
 https://github.com/wltrup

 or

 WTOnlineLinearRegression by Wagner Truppel
 https://github.com/wltrup
 */

import Foundation


/// An enumeration describing some of the possible errors that can be thrown when
/// using the APIs provided by **WTOnlineLinearRegression**.
///
/// - **negativeValue**:
///            thrown when a function expects a non-negative argument but
///            receives a negative value for it.
///
/// - **negativeVariance**:
///            thrown when a function expects a variance-like argument and
///            receives a negative value for it.
///
/// - **negativeStandardDeviation**:
///            thrown when a function expects a standard-deviation-like argument
///            and receives a negative value for it.
///
/// `BFPType` is any `BinaryFloatingPoint` type such as `Double` or `CGFloat`.
///
public enum InvalidArgumentError<BFPType: BinaryFloatingPoint>: Error, Equatable
{
    case negativeValue(BFPType)
    case negativeVariance(BFPType)
    case negativeStandardDeviation(BFPType)

    // MARK: - Equatable conformance

    /// Implements conformance to the `Equatable` protocol.
    ///
    /// - Parameters:
    ///   - lhs: the first operand.
    ///   - rhs: the second operand.
    //
    /// - Returns: whether or not the two instances are considered equal.
    //
    public static func ==(lhs: InvalidArgumentError, rhs: InvalidArgumentError) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.negativeValue(let value1),
              .negativeValue(let value2)):
            return value1 == value2

        case (.negativeVariance(let value1),
              .negativeVariance(let value2)):
            return value1 == value2

        case (.negativeStandardDeviation(let value1),
              .negativeStandardDeviation(let value2)):
            return value1 == value2

        default:
            return false
        }
    }
}

