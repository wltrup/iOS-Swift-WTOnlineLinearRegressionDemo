/*
 UncertainValue.swift
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


/// This struct encapsulates the notion of a statistically uncertain quantity,
/// ie, a quantity that has a value but also some variance. It is typically
/// associated with a collection of measurements of some kind.
///
/// `BFPType` is any `BinaryFloatingPoint` type such as `Double` or `CGFloat`.
///
public struct UncertainValue<BFPType: BinaryFloatingPoint>: Equatable
{
    /// The uncertain value itself. It's often the mean of a collection
    /// of measurements but need not be so.
    public let value: BFPType

    /// The uncertain value's variance, a non-negative quantity.
    public let variance: BFPType

    /// The uncertain value's standard deviation, a non-negative quantity
    /// equal to the square-root of the value's variance.
    /// It's available here for convenience.
    public let standardDeviation: BFPType

    // MARK: - Initializers

    /// One of the designated initializers.
    /// Initialises an instance with all-zero values.
    ///
    public init()
    {
        self.value = 0
        self.variance = 0
        self.standardDeviation = 0
    }

    /// One of the designated initializers.
    ///
    /// - Parameters:
    ///   - value: the uncertain value proper.
    ///   - variance: the value's variance.
    ///               This should be a non-negative value.
    ///
    /// - Throws: InvalidArgumentError.negativeVariance
    ///           when the variance is negative.
    ///
    public init(value: BFPType, variance: BFPType) throws
    {
        guard variance >= 0 else {
            throw InvalidArgumentError.negativeVariance(variance)
        }

        self.value = value
        self.variance = variance
        self.standardDeviation = sqrt(variance)
    }

    /// One of the designated initializers.
    ///
    /// - Parameters:
    ///   - value: the uncertain value proper.
    ///   - standardDeviation: the value's standardDeviation.
    ///                        This should be a non-negative value.
    ///
    /// - Throws: InvalidArgumentError.negativeStandardDeviation
    ///           when the standard deviation is negative.
    ///
    public init(value: BFPType, standardDeviation: BFPType) throws
    {
        guard standardDeviation >= 0 else {
            throw InvalidArgumentError.negativeStandardDeviation(standardDeviation)
        }

        self.value = value
        self.variance = standardDeviation * standardDeviation
        self.standardDeviation = standardDeviation
    }

    // MARK: - Equatable conformance

    /// Implements conformance to the `Equatable` protocol.
    ///
    /// - Parameters:
    ///   - lhs: the first operand.
    ///   - rhs: the second operand.
    ///
    /// - Returns: whether or not the two instances are considered equal.
    ///
    public static func ==(lhs: UncertainValue, rhs: UncertainValue) -> Bool
    {
        return lhs.value == rhs.value &&
            lhs.variance == rhs.variance &&
            lhs.standardDeviation == rhs.standardDeviation
    }
}

