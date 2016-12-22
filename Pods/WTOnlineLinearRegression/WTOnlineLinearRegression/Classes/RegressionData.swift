/*
 RegressionData.swift
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


/// This struct encapsulates the data and results associated with the linear
/// regression of a set of observations.
///
/// `BFPType` is any `BinaryFloatingPoint` type such as `Double` or `CGFloat`.
///
public struct RegressionData<BFPType: BinaryFloatingPoint>: Equatable, Comparable
{
    /// A property that can be used to order the instances in some fashion.
    public let index: Int

    /// The collection of observations used to perform the linear regression
    /// associated with this instance.
    public let observations: [Observation<BFPType>]

    /// The number of observations in the set of observations used to
    /// perform the linear regression associated with this instance.
    public var numberOfObservations: Int { return observations.count }

    /// The sum of the observations' (1 over y-variance) values over the
    /// collection of observations used to perform the linear regression
    /// associated with this instance.
    public let sumOneOverVarianceY: BFPType

    /// The sum of the observations' (x over y-variance) values over the
    /// collection of observations used to perform the linear regression
    /// associated with this instance.
    public let sumXoverVarianceY: BFPType

    /// The sum of the observations' (y over y-variance) values over the
    /// collection of observations used to perform the linear regression
    /// associated with this instance.
    public let sumYoverVarianceY: BFPType

    /// The sum of the observations' (x times y over y-variance) values
    /// over the collection of observations used to perform the linear
    ///regression associated with this instance.
    public let sumXYoverVarianceY: BFPType

    /// The sum of the observations' (x-squared over y-variance) values
    /// over the collection of observations used to perform the linear
    ///regression associated with this instance.
    public let sumXsquaredOverVarianceY: BFPType

    /// The sum of the observations' (y-squared over y-variance) values
    /// over the collection of observations used to perform the linear
    ///regression associated with this instance.
    public let sumYsquaredOverVarianceY: BFPType

    /// The **mean total squared error** associated with the set of
    /// observations.
    public let meanTotalSquaredError: BFPType

    /// The **mean squared residual error** of the best regression line
    /// representing the set of observations used to perform the linear
    /// regression associated with this instance. It's an optional type
    /// because the mean squared residual error is not alwways defined.
    public let meanSquaredResidualError: BFPType?

    /// The **mean squared regression error** of the best regression line
    /// representing the set of observations used to perform the linear
    /// regression associated with this instance. It's an optional type
    /// because the mean squared regression error is not alwways defined.
    public let meanSquaredRegressionError: BFPType?

    /// The **R-squared** quality measure of the best regression line
    /// representing the set of observations used to perform the linear
    /// regression associated with this instance. The closer this value
    /// is to 1.0 the better the regression line fits the observations.
    /// It's an optional type because there may not yet be enough
    /// observations to compute a regression line.
    /// See [coefficient of determination](https://en.wikipedia.org/wiki/Coefficient_of_determination)
    /// for details on how it's computed.
    public let rSquared: BFPType?

    /// The parameters of the best regression line representing the
    /// set of observations used to perform the linear regression associated
    /// with this instance. It's an optional type because there may not yet
    /// be enough observations to compute a regression line.
    public let equation: RegressionEquation<BFPType>?

    // MARK: - Initializers

    /// One of the designated initializers.
    /// Initialises an instance with all-zero values.
    ///
    /// This initializer is *internal*.
    ///
    init(index: Int = 0)
    {
        self.index = index
        self.observations = []
        self.sumOneOverVarianceY = 0
        self.sumXoverVarianceY = 0
        self.sumYoverVarianceY = 0
        self.sumXYoverVarianceY = 0
        self.sumXsquaredOverVarianceY = 0
        self.sumYsquaredOverVarianceY = 0
        self.meanTotalSquaredError = 0
        self.meanSquaredResidualError = nil
        self.meanSquaredRegressionError = nil
        self.rSquared = nil
        self.equation = nil
    }

    /// One of the designated initializers.
    ///
    /// This initializer is *internal*.
    ///
    /// - Parameters:
    ///   - index: index value.
    ///   - observations: observations value.
    ///   - sumOneOverVarianceY: sumOneOverVarianceY value.
    ///   - sumXoverVarianceY: sumXoverVarianceY value.
    ///   - sumYoverVarianceY: sumYoverVarianceY value.
    ///   - sumXYoverVarianceY: sumXYoverVarianceY value.
    ///   - sumXsquaredOverVarianceY: sumXsquaredOverVarianceY value.
    ///   - sumYsquaredOverVarianceY: sumYsquaredOverVarianceY value.
    ///   - meanTotalSquaredError: meanTotalSquaredError value.
    ///   - meanSquaredResidualError: meanSquaredResidualError value.
    ///   - meanSquaredRegressionError: meanSquaredRegressionError value.
    ///   - rSquared: rSquared value.
    ///   - equation: equation value.
    ///
    /// - Throws: InvalidArgumentError.negativeValue
    ///           if `sumOneOverVarianceY` is less than zero or
    ///           if `sumXsquaredOverVarianceY` is less than zero or
    ///           if `sumYsquaredOverVarianceY` is less than zero or
    ///           if `meanTotalSquaredError` is less than zero or
    ///           if `meanSquaredResidualError` is less than zero or
    ///           if `meanSquaredRegressionError` is less than zero or
    ///           if `rSquared` is less than zero.
    ///
    init(index: Int,
         observations: [Observation<BFPType>],
         sumOneOverVarianceY: BFPType,
         sumXoverVarianceY: BFPType,
         sumYoverVarianceY: BFPType,
         sumXYoverVarianceY: BFPType,
         sumXsquaredOverVarianceY: BFPType,
         sumYsquaredOverVarianceY: BFPType,
         meanTotalSquaredError: BFPType,
         meanSquaredResidualError: BFPType?,
         meanSquaredRegressionError: BFPType?,
         rSquared: BFPType?,
         equation: RegressionEquation<BFPType>?) throws
    {
        guard sumOneOverVarianceY >= 0 else {
            throw InvalidArgumentError.negativeValue(sumOneOverVarianceY)
        }

        guard sumXsquaredOverVarianceY >= 0 else {
            throw InvalidArgumentError.negativeValue(sumXsquaredOverVarianceY)
        }

        guard sumYsquaredOverVarianceY >= 0 else {
            throw InvalidArgumentError.negativeValue(sumYsquaredOverVarianceY)
        }

        guard meanTotalSquaredError >= 0 else {
            throw InvalidArgumentError.negativeValue(meanTotalSquaredError)
        }

        if let meanSquaredResidualError = meanSquaredResidualError
        {
            guard meanSquaredResidualError >= 0 else {
                throw InvalidArgumentError.negativeValue(meanSquaredResidualError)
            }
        }

        if let meanSquaredRegressionError = meanSquaredRegressionError
        {
            guard meanSquaredRegressionError >= 0 else {
                throw InvalidArgumentError.negativeValue(meanSquaredRegressionError)
            }
        }

        if let rSquared = rSquared
        {
            guard rSquared >= 0 else {
                throw InvalidArgumentError.negativeValue(rSquared)
            }
        }

        self.index = index
        self.observations = observations
        self.sumOneOverVarianceY = sumOneOverVarianceY
        self.sumXoverVarianceY = sumXoverVarianceY
        self.sumYoverVarianceY = sumYoverVarianceY
        self.sumXYoverVarianceY = sumXYoverVarianceY
        self.sumXsquaredOverVarianceY = sumXsquaredOverVarianceY
        self.sumYsquaredOverVarianceY = sumYsquaredOverVarianceY
        self.meanTotalSquaredError = meanTotalSquaredError
        self.meanSquaredResidualError = meanSquaredResidualError
        self.meanSquaredRegressionError = meanSquaredRegressionError
        self.rSquared = rSquared
        self.equation = equation
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
    public static func ==(lhs: RegressionData, rhs: RegressionData) -> Bool
    {
        return lhs.index == rhs.index &&
            lhs.observations == rhs.observations &&
            lhs.sumOneOverVarianceY == rhs.sumOneOverVarianceY &&
            lhs.sumXoverVarianceY == rhs.sumXoverVarianceY &&
            lhs.sumYoverVarianceY == rhs.sumYoverVarianceY &&
            lhs.sumXYoverVarianceY == rhs.sumXYoverVarianceY &&
            lhs.sumXsquaredOverVarianceY == rhs.sumXsquaredOverVarianceY &&
            lhs.sumYsquaredOverVarianceY == rhs.sumYsquaredOverVarianceY &&
            lhs.meanTotalSquaredError == rhs.meanTotalSquaredError &&
            lhs.meanSquaredResidualError == rhs.meanSquaredResidualError &&
            lhs.meanSquaredRegressionError == rhs.meanSquaredRegressionError &&
            lhs.rSquared == rhs.rSquared &&
            lhs.equation == rhs.equation
    }

    // MARK: - Comparable conformance

    /// Implements conformance to the `Comparable` protocol.
    ///
    /// - Parameters:
    ///   - lhs: the first operand.
    ///   - rhs: the second operand.
    ///
    /// - Returns: whether or not the two instances are ordered according
    ///            to their `index` values.
    ///
    public static func <(lhs: RegressionData, rhs: RegressionData) -> Bool
    { return lhs.index < rhs.index }
}

