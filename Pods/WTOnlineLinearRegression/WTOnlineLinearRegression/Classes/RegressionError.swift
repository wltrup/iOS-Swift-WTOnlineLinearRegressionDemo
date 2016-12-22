/*
 RegressionError.swift
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


/// An enumeration describing the possible errors that can be thrown when
/// using the APIs provided by **WTOnlineLinearRegression**.
///
/// - **invalidMinimumVarianceInY**:
///            thrown when the initialiser is passed a negative or zero
///            value for the `minimumVarianceInY` argument.
///
/// - **cannotRemoveObservationFromEmptyCollection**:
///            thrown when an attempt is made to remove an observation when
///            no observations have been processed yet.
///
/// - **cannotRemoveNonExistingObservation**:
///            thrown when an attempt is made to remove an observation that
///            has never been processed.
///
/// `BFPType` is any `BinaryFloatingPoint` type such as `Double` or `CGFloat`.
///
public enum RegressionError<BFPType: BinaryFloatingPoint>: Error, Equatable
{
    case invalidMinimumVarianceInY(BFPType)
    case cannotRemoveObservationFromEmptyCollection(Observation<BFPType>)
    case cannotRemoveNonExistingObservation(Observation<BFPType>)

    // MARK: - Equatable conformance

    /// Implements conformance to the `Equatable` protocol.
    ///
    /// - Parameters:
    ///   - lhs: the first operand.
    ///   - rhs: the second operand.
    //
    /// - Returns: whether or not the two instances are considered equal.
    //
    public static func ==(lhs: RegressionError,
                          rhs: RegressionError) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.invalidMinimumVarianceInY(let var1),
              .invalidMinimumVarianceInY(let var2)):
            return var1 == var2

        case (.cannotRemoveObservationFromEmptyCollection(let obs1),
              .cannotRemoveObservationFromEmptyCollection(let obs2)):
            return obs1 == obs2

        case (.cannotRemoveNonExistingObservation(let obs1),
              .cannotRemoveNonExistingObservation(let obs2)):
            return obs1 == obs2

        default:
            return false
        }
    }
}

