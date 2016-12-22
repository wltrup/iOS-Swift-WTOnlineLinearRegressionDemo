/*
 RegressionEquation.swift
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


/// This enumeration encapsulates the resulting line associated with a
/// linear regression performed on a set of observations.
///
/// - SeeAlso: `RegressionData`
/// - SeeAlso: `LinearRegression`
/// - SeeAlso: `Observation`
/// - SeeAlso: `UncertainValue`
///
/// `BFPType` is any `BinaryFloatingPoint` type such as `Double` or `CGFloat`.
///
public enum RegressionEquation<BFPType: BinaryFloatingPoint>: Equatable
{
    /// Represents a line that is not vertical.
    case finiteSlope(slope: UncertainValue<BFPType>, interceptY: UncertainValue<BFPType>)

    /// Represents a vertical line.
    case infiniteSlope(interceptX: BFPType)

    /// Represents a degenerate line corresponding to a single point.
    /// This happens when attempting to do a regression on several
    /// **identical** observations.
    case degenerate(x: BFPType, y: BFPType)

    // MARK: -

    /// A convenience property so client code doesn't have to use `switch`
    /// statements all the time.
    public var isDegenerate: Bool {
        switch self
        {
        case .degenerate(_, _):
            return true

        default:
            return false
        }
    }

    /// A convenience property so client code doesn't have to use `switch`
    /// statements all the time.
    public var hasFiniteSlope: Bool {
        switch self
        {
        case .finiteSlope(_, _):
            return true

        default:
            return false
        }
    }

    /// A convenience property so client code doesn't have to use `switch`
    /// statements all the time.
    public var hasZeroSlope: Bool {
        switch self
        {
        case .finiteSlope(let slope, _):
            return slope.value == 0

        default:
            return false
        }
    }

    /// The regression line's slope.
    public var slope: UncertainValue<BFPType>? {
        switch self
        {
        case .finiteSlope(let slope, _):
            return slope

        default:
            return nil
        }
    }

    /// The value of Y at which the regression line crosses the Y axis.
    public var interceptY: UncertainValue<BFPType>? {
        switch self
        {
        case .finiteSlope(_, let interceptY):
            return interceptY

        default:
            return nil
        }
    }

    /// The value of X at which the regression line crosses the X axis.
    public var interceptX: BFPType? {
        if self.hasZeroSlope { return nil }
        switch self
        {
        case .finiteSlope(let slope, let interceptY):
            return -(interceptY.value / slope.value)

        case .infiniteSlope(let interceptX):
            return interceptX

        default:
            return nil
        }
    }

    // MARK: - Equatable conformance

    /// Implements conformance to the `Equatable` protocol.
    ///
    /// - Parameters:
    ///   - lhs: the first operand.
    ///   - rhs: the second operand.
    //
    /// - Returns: whether or not the two instances are considered equal.
    //
    public static func ==(lhs: RegressionEquation, rhs: RegressionEquation) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.finiteSlope(let slope1, let interceptY1),
              .finiteSlope(let slope2, let interceptY2)):
            return slope1 == slope2 && interceptY1 == interceptY2

        case (.infiniteSlope(let interceptX1),
              .infiniteSlope(let interceptX2)):
            return interceptX1 == interceptX2

        case (.degenerate(let interceptX1, let interceptY1),
              .degenerate(let interceptX2, let interceptY2)):
            return interceptX1 == interceptX2 && interceptY1 == interceptY2
            
        default:
            return false
        }
    }
}

