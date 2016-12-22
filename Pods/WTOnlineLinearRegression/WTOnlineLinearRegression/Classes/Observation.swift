/*
 Observation.swift
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


// MARK: -

/// A struct representing an observation of some empirical data.
///
/// `BFPType` is any `BinaryFloatingPoint` type such as `Double` or `CGFloat`.
///
public struct Observation<BFPType: BinaryFloatingPoint>: Equatable
{
    // MARK: - Public properties

    /// The value of the independent variable in this observation.
    public let x: BFPType

    /// The value of the dependent variable in this observation.
    /// This is a composite value, having a value, a variance, and
    /// a standard deviation.
    ///
    /// - SeeAlso: `UncertainValue`
    public let y: UncertainValue<BFPType>

    /// This property indicates whether or not this observation has an
    /// uncertain dependent value.
    public var yHasVariance: Bool { return y.variance != 0 }

    // MARK: - Initializers

    /// One of the several designated initializers.
    ///
    /// - Parameters:
    ///   - x: the value of the independent variable in this observation.
    ///   - y: the (composite) value of the dependent variable in this observation.
    ///
    public init(x: BFPType, y: UncertainValue<BFPType>)
    {
        self.x = x
        self.y = y
    }

    /// One of the several designated initializers.
    ///
    /// - Parameters:
    ///   - x: the value of the independent variable in this observation.
    ///   - y: the value of the dependent variable in this observation.
    ///   - yVariance:
    ///                The variance in the dependent variable of this observation.
    ///                Its default value is zero.
    ///
    /// - Throws: InvalidArgumentError.negativeVariance if
    ///           `yVariance` is less than zero.
    ///
    public init(x: Int, y: Int, yVariance: BFPType = 0) throws
    { try self.init(x: BFPType(x), y: BFPType(y), yVariance: yVariance) }

    /// One of the several designated initializers.
    ///
    /// - Parameters:
    ///   - x: the value of the independent variable in this observation.
    ///   - y: the value of the dependent variable in this observation.
    ///   - yStandardDeviation:
    ///                The standard deviation in the dependent variable of
    ///                this observation.
    ///
    /// - Throws: InvalidArgumentError.negativeStandardDeviation if
    ///           `yStandardDeviation` is less than zero.
    ///
    public init(x: Int, y: Int, yStandardDeviation: BFPType) throws
    { try self.init(x: BFPType(x), y: BFPType(y), yStandardDeviation: yStandardDeviation) }

    /// One of the several designated initializers.
    ///
    /// - Parameters:
    ///   - x: the value of the independent variable in this observation.
    ///   - y: the value of the dependent variable in this observation.
    ///   - yVariance:
    ///                The variance in the dependent variable of this observation.
    ///                Its default value is zero.
    ///
    /// - Throws: InvalidArgumentError.negativeVariance if
    ///           `yVariance` is less than zero.
    ///
    public init(x: Int, y: BFPType, yVariance: BFPType = 0) throws
    { try self.init(x: BFPType(x), y: y, yVariance: yVariance) }

    /// One of the several designated initializers.
    ///
    /// - Parameters:
    ///   - x: the value of the independent variable in this observation.
    ///   - y: the value of the dependent variable in this observation.
    ///   - yStandardDeviation:
    ///                The standard deviation in the dependent variable of
    ///                this observation.
    ///
    /// - Throws: InvalidArgumentError.negativeStandardDeviation if
    ///           `yStandardDeviation` is less than zero.
    ///
    public init(x: Int, y: BFPType, yStandardDeviation: BFPType) throws
    { try self.init(x: BFPType(x), y: y, yStandardDeviation: yStandardDeviation) }

    /// One of the several designated initializers.
    ///
    /// - Parameters:
    ///   - x: the value of the independent variable in this observation.
    ///   - y: the value of the dependent variable in this observation.
    ///   - yVariance:
    ///                The variance in the dependent variable of this observation.
    ///                Its default value is zero.
    ///
    /// - Throws: InvalidArgumentError.negativeVariance if
    ///           `yVariance` is less than zero.
    ///
    public init(x: BFPType, y: Int, yVariance: BFPType = 0) throws
    { try self.init(x: x, y: BFPType(y), yVariance: yVariance) }

    /// One of the several designated initializers.
    ///
    /// - Parameters:
    ///   - x: the value of the independent variable in this observation.
    ///   - y: the value of the dependent variable in this observation.
    ///   - yStandardDeviation:
    ///                The standard deviation in the dependent variable of
    ///                this observation.
    ///
    /// - Throws: InvalidArgumentError.negativeStandardDeviation if
    ///           `yStandardDeviation` is less than zero.
    ///
    public init(x: BFPType, y: Int, yStandardDeviation: BFPType) throws
    { try self.init(x: x, y: BFPType(y), yStandardDeviation: yStandardDeviation) }

    /// One of the several designated initializers.
    ///
    /// - Parameters:
    ///   - x: the value of the independent variable in this observation.
    ///   - y: the value of the dependent variable in this observation.
    ///   - yVariance: The variance in the dependent variable of this observation.
    ///
    /// - Throws: InvalidArgumentError.negativeVariance if
    ///           `yVariance` is less than zero.
    ///
    public init(x: BFPType, y: BFPType, yVariance: BFPType = 0) throws
    {
        guard yVariance >= 0 else {
            throw InvalidArgumentError.negativeVariance(yVariance)
        }

        self.x = x
        self.y = try UncertainValue<BFPType>(value: y,
                                             variance: yVariance)
    }

    /// One of the several designated initializers.
    ///
    /// - Parameters:
    ///   - x: the value of the independent variable in this observation.
    ///   - y: the value of the dependent variable in this observation.
    ///   - yStandardDeviation:
    ///                The standard deviation in the dependent variable of
    ///                this observation.
    ///
    /// - Throws: InvalidArgumentError.negativeStandardDeviation if
    ///           `yStandardDeviation` is less than zero.
    ///
    public init(x: BFPType, y: BFPType, yStandardDeviation: BFPType) throws
    {
        guard yStandardDeviation >= 0 else {
            throw InvalidArgumentError.negativeStandardDeviation(yStandardDeviation)
        }

        self.x = x
        self.y = try UncertainValue<BFPType>(value: y,
                                             standardDeviation: yStandardDeviation)
    }

    /// Creates, initialises, and returns a new instance equal to `self`
    /// but with the specified **variance** for the dependent variable.
    ///
    /// - Parameter yStdDev: the desired standard deviation.
    /// - Returns: a new instance equal to `self` but with the specified
    ///            **variance** for the dependent variable.
    ///
    /// - Throws: InvalidArgumentError.negativeVariance if
    ///           `yVariance` is less than zero.
    ///
    public func with(yVariance: BFPType) throws -> Observation
    {
        guard yVariance >= 0 else {
            throw InvalidArgumentError.negativeVariance(yVariance)
        }

        return try Observation(x: self.x,
                               y: self.y.value,
                               yVariance: yVariance)
    }

    /// Creates, initialises, and returns a new instance equal to `self`
    /// but with the specified **standard deviation** for the dependent
    /// variable.
    ///
    /// - Parameter yStdDev: the desired standard deviation.
    /// - Returns: a new instance equal to `self` but with the specified
    ///            **standard deviation** for the dependent variable.
    ///
    /// - Throws: InvalidArgumentError.negativeStandardDeviation if
    ///           `yStandardDeviation` is less than zero.
    ///
    public func with(yStandardDeviation: BFPType) throws -> Observation
    {
        guard yStandardDeviation >= 0 else {
            throw InvalidArgumentError.negativeStandardDeviation(yStandardDeviation)
        }

        return try Observation(x: self.x,
                               y: self.y.value,
                               yStandardDeviation: yStandardDeviation)
    }

    // MARK: - Equatable conformance

    /// Implements conformance to the `Equatable` protocol.
    ///
    /// - Parameters:
    ///   - lhs: the first operand.
    ///   - rhs: the second operand.
    ///
    /// - Returns: whether or not the two `Observation` instances are considered equal.
    ///
    public static func ==(lhs: Observation, rhs: Observation) -> Bool
    { return lhs.x == rhs.x && lhs.y == rhs.y }
}

