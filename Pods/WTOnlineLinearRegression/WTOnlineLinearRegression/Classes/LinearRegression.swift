/*
 LinearRegression.swift
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


/// Instances of this class perform a linear regression, with or without variances
/// in the dependent variable (traditionally referred to as the Y value), with an
/// O(1) complexity per observation, in both space and time. In other words, this
/// class does not use the entire history of observations but updates its properties
/// as each new observation is added.
///
/// However, you may request the instance to record the history of observations and
/// their results. The computations are still done in constant time and space but,
/// obviously, storing the entire history after every observation may occupy quite
/// a bit of space.
///
/// `BFPType` is any `BinaryFloatingPoint` type such as `Double` or `CGFloat`.
///
public final class LinearRegression<BFPType: BinaryFloatingPoint>
{
    // MARK: - Initializers

    /// This is the class designated initializer. It initializes a new instance
    /// of `LinearRegression` with the desired option for whether or not to ignore
    /// variances in the observations' Y values. Only the variances may be ignored;
    /// the observations X and Y values are never ignored.
    ///
    /// In the event that y-variances are *not* being ignored (`ignoringVarianceInY`
    /// is set to `false`), it's necessary for **every** observation to have a
    /// *non-zero* y variance. To enforce that requirement without throwing an error
    /// every time it's not fulfilled, each observation with a zero y-variance will be
    /// assigned a new y-variance, given by `minimumVarianceInY`. This **only** happens
    /// to observations that have zero y-variance and **only** when `ignoringVarianceInY`
    /// is set to `false`. 'minimumVarianceInY' has a very small default value but its
    /// value can be changed at initialisation time.
    ///
    /// You may also require the instance to record a history of its observations and
    /// the resulting data and regressed line by setting the `keepingHistory` argument.
    /// This argument is matched by a property that can be toggled at any time, to
    /// temporarily stop and then resume keeping the history. The demo app shows an
    /// example of why this may be useful.
    ///
    /// - Parameters:
    ///   - ignoringVarianceInY:
    ///           whether or not to ignore variances in the observations' Y values.
    ///
    ///   - minimumVarianceInY:
    ///           in the event that y-variances are not being ignored, this is the
    ///           variance used for observations that have no y-variance of their own.
    ///           Having such a minimum variance is necessary to avoid numerical
    ///           instabilities. The default value is 1e-10.
    ///
    ///   - keepingHistory:
    ///           whether or not to keep a history of observations and the
    ///           resulting data and regressed line. The default behaviour
    ///           is **not** to keep the history of observations.
    ///
    /// - Throws: RegressionError.invalidMinimumVarianceInY if
    ///           `minimumVarianceInY` is less than or equal to zero.
    ///
    public init(ignoringVarianceInY: Bool,
                minimumVarianceInY: BFPType = 1e-10,
                keepingHistory: Bool = false) throws
    {
        guard minimumVarianceInY > 0 else {
            throw RegressionError.invalidMinimumVarianceInY(minimumVarianceInY)
        }

        self.ignoringVarianceInY = ignoringVarianceInY
        self.minimumVarianceInY = minimumVarianceInY
        self.keepingHistory = keepingHistory

        self.history = [RegressionData<BFPType>]()
        self.currentData = RegressionData<BFPType>()
    }

    // MARK: - Public properties

    /// A property indicating whether or not to ignore variances in the observations'
    /// Y values. Only the variances may be ignored; the observations X and Y values
    /// are never ignored.
    public let ignoringVarianceInY: Bool

    /// The variance used for observations that have no y-variance of their own.
    /// This value is only used when `ignoringVarianceInY` is set to `false`.
    public let minimumVarianceInY: BFPType

    /// A property indicating whether or not this instance of `LinearRegression` should
    /// store the entire history of observations and the resulting data and regressed
    /// line as those observations are processed. It can be toggled at any time, to
    /// temporarily stop and then resume keeping the history.
    public var keepingHistory: Bool

    /// A composite type storing the entire history of observations (and their
    /// regression data) as they're processed by this instance of `LinearRegression`.
    ///
    /// - SeeAlso: `RegressionData`
    public fileprivate(set) var history: [RegressionData<BFPType>]

    /// A composite type storing the regression data associated with all the
    /// obervations processed so far.
    ///
    /// - SeeAlso: `RegressionData`
    public fileprivate(set) var currentData: RegressionData<BFPType>

    // MARK: - Methods

    /// Processes a new observation by "adding" it to the collection of observations.
    /// Adding an observation runs in **constant** time on the number of existing
    /// observations.
    ///
    /// - Parameter observation: the new observation to "add".
    ///
    public func add(_ observation: Observation<BFPType>)
    { process(observation, indexToRemove: nil) }

    /// Processes a new observation by "removing" it from the collection of
    /// observations. Removing an observation is useful, for instance, when
    /// considering a "moving window" of observations: as new observations
    /// are added, older ones are removed, resulting in a "running" regression
    /// line.
    ///
    /// - Note: Removing an observation scans the current list of observations
    ///         to make sure the observation to be removed was once added.
    ///         Therefore, `remove(:)` runs in **linear time** on the number of
    ///         existing observations.
    ///
    /// - Parameter observation: the observation to remove.
    ///
    /// - Throws: RegressionError.cannotRemoveObservationFromEmptyCollection
    ///           when an attempt is made to remove an observation when none have
    ///           been processed yet.
    ///
    /// - Throws: RegressionError.cannotRemoveNonExistingObservation
    ///           when an attempt is made to remove an observation that has never
    ///           been processed.
    ///
    public func remove(_ observation: Observation<BFPType>) throws
    {
        guard currentData.numberOfObservations > 0 else {
            throw RegressionError.cannotRemoveObservationFromEmptyCollection(observation)
        }

        var index: Int? = nil
        for (offset, element) in currentData.observations.enumerated()
        { if element == observation { index = offset; break } }

        guard index != nil else {
            throw RegressionError.cannotRemoveNonExistingObservation(observation)
        }

        process(observation, indexToRemove: index)
    }

    // MARK: - Private properties

    fileprivate var adding: Bool = false
    fileprivate var sign: BFPType = 0

    fileprivate var newNumObs = 0

    fileprivate var x: BFPType = 0
    fileprivate var y: BFPType = 0
    fileprivate var xy: BFPType  = 0
    fileprivate var xsq: BFPType = 0
    fileprivate var ysq: BFPType = 0

    fileprivate var yvar: BFPType = 0
    fileprivate var oneovar: BFPType = 0
    fileprivate var xovar: BFPType = 0
    fileprivate var yovar: BFPType = 0
    fileprivate var xyovar: BFPType = 0
    fileprivate var xsqovar: BFPType = 0
    fileprivate var ysqovar: BFPType = 0

    fileprivate var newSumOne: BFPType = 0

    fileprivate var newSumX: BFPType = 0
    fileprivate var newMeanX: BFPType = 0

    fileprivate var newSumY: BFPType = 0
    fileprivate var newMeanY: BFPType = 0

    fileprivate var newSumXY: BFPType = 0
    fileprivate var newMeanXY: BFPType = 0

    fileprivate var newSumXsq: BFPType = 0
    fileprivate var newMeanXsq: BFPType = 0

    fileprivate var newSumYsq: BFPType = 0
    fileprivate var newMeanYsq: BFPType = 0

    fileprivate var newDelta: BFPType = 0
    fileprivate var newDeltaTimesSlope: BFPType = 0
    fileprivate var newDeltaTimesIntcptY: BFPType = 0

    fileprivate var newMeanTotalSE: BFPType = 0

    fileprivate var newEquation: RegressionEquation<BFPType>? = nil
    fileprivate var newMeanResidualSE: BFPType? = nil
    fileprivate var newMeanRegressionSE: BFPType? = nil
    fileprivate var newRsquared: BFPType? = nil
}

// MARK: - Private API

extension LinearRegression
{
    fileprivate func process(_ observation: Observation<BFPType>, indexToRemove: Int?)
    {
        adding = (indexToRemove == nil)
        sign = (adding ? 1 : -1)

        newNumObs = currentData.numberOfObservations + (adding ? 1 : -1)

        guard newNumObs > 0 else {
            resetAllValues()
            updateHistory()
            return
        }

        computeBasicQuantities(observation)

        if newNumObs == 1
        {
            // we don't have enough data to compute a regression line.
            resetEquationRelatedQuantities()
        }
        else // newNumObs >= 2
        {
            // If adding:
            // we have at least 2 observations after having added the new observation
            // and can then compute a regression line.

            // If removing:
            // we still have at least 2 observations after having removed the observation
            // in question and can still compute a regression line.

            if newDelta == 0
            {
                if newMeanTotalSE == 0
                { processDegenerateLine() }
                else
                { processLineWithInfiniteSlope() }
            }
            else
            { processLineWithFiniteSlope() }
        }

        updateCurrentData(observation, indexToRemove: indexToRemove)
        updateHistory()
    }

    fileprivate func resetAllValues()
    { currentData = RegressionData(index: currentData.index + 1) }

    fileprivate func updateHistory()
    {
        guard keepingHistory else { return }
        history += [currentData]
    }

    fileprivate func safe(_ observation: Observation<BFPType>) -> Observation<BFPType>
    {
        let safeObs: Observation<BFPType>
        if !ignoringVarianceInY && !observation.yHasVariance
        { safeObs = try! observation.with(yVariance: minimumVarianceInY) }
        else
        { safeObs = observation }
        return safeObs
    }

    fileprivate func computeBasicQuantities(_ observation: Observation<BFPType>)
    {
        let safeObs = safe(observation)

        x = safeObs.x
        y = safeObs.y.value
        xy  = x * y
        xsq = x * x
        ysq = y * y

        yvar = (ignoringVarianceInY ? 1 : safeObs.y.variance)
        oneovar = 1   / yvar
        xovar   = x   / yvar
        yovar   = y   / yvar
        xyovar  = xy  / yvar
        xsqovar = xsq / yvar
        ysqovar = ysq / yvar

        newSumOne = currentData.sumOneOverVarianceY      + sign * oneovar
        newSumOne = max(0, newSumOne) // since round-off errors may make this negative

        newSumX   = currentData.sumXoverVarianceY        + sign * xovar
        newSumY   = currentData.sumYoverVarianceY        + sign * yovar
        newSumXY  = currentData.sumXYoverVarianceY       + sign * xyovar

        newSumXsq = currentData.sumXsquaredOverVarianceY + sign * xsqovar
        newSumXsq = max(0, newSumXsq) // since round-off errors may make this negative

        newSumYsq = currentData.sumYsquaredOverVarianceY + sign * ysqovar
        newSumYsq = max(0, newSumYsq) // since round-off errors may make this negative

        newMeanX   = newSumX   / newSumOne
        newMeanY   = newSumY   / newSumOne
        newMeanXY  = newSumXY  / newSumOne
        newMeanXsq = newSumXsq / newSumOne
        newMeanYsq = newSumYsq / newSumOne

        newDelta = newMeanXsq - newMeanX * newMeanX
        newDelta = max(0, newDelta) // since round-off errors may make this negative

        newDeltaTimesSlope = newMeanXY - newMeanX * newMeanY
        newDeltaTimesIntcptY = newMeanXsq * newMeanY - newMeanX * newMeanXY

        newMeanTotalSE = newMeanYsq - newMeanY * newMeanY
        newMeanTotalSE = max(0, newMeanTotalSE) // since round-off errors may make this negative
    }

    fileprivate func resetEquationRelatedQuantities()
    {
        newEquation = nil
        newMeanResidualSE = nil
        newMeanRegressionSE = nil
        newRsquared = nil
    }

    fileprivate func processDegenerateLine()
    {
        resetEquationRelatedQuantities()
        newEquation = RegressionEquation.degenerate(x: newMeanX, y: newMeanY)
    }

    fileprivate func processLineWithInfiniteSlope()
    {
        resetEquationRelatedQuantities()

        newRsquared = 1 // vertical line
        newEquation = RegressionEquation.infiniteSlope(interceptX: newMeanX)
    }

    fileprivate func processLineWithFiniteSlope()
    {
        let a = newDeltaTimesSlope   / newDelta
        let b = newDeltaTimesIntcptY / newDelta

        newMeanResidualSE =
            newMeanYsq - (newMeanXY * a + newMeanY * b)
        newMeanResidualSE = max(0, newMeanResidualSE!) // since round-off errors may make this negative

        newMeanRegressionSE =
            (newMeanXY - 2 * newMeanX * newMeanY) * a + (newMeanY - b) * newMeanY
        newMeanRegressionSE = max(0, newMeanRegressionSE!) // since round-off errors may make this negative

        if newMeanTotalSE == 0
        { newRsquared = 1 } // horizontal line
        else
        { newRsquared = 1 - (newMeanResidualSE! / newMeanTotalSE) }

        newRsquared = max(0, newRsquared!) // since round-off errors may make this negative
        newRsquared = min(newRsquared!, 1) // since round-off errors may push this above 1

        let u = newMeanResidualSE! / newDelta
        let f: BFPType = (newNumObs == 2 ? 1 : 2)     // This is a bit of a hack, but it's ok because
        var aVar = (4 * u) / (BFPType(newNumObs) - f) // we get a higher var for only 2 observations
        aVar = max(0, aVar) // since round-off errors may make this negative

        let bVar = aVar * newMeanXsq

        let slope   = try! UncertainValue(value: a, variance: aVar)
        let intcptY = try! UncertainValue(value: b, variance: bVar)

        newEquation = RegressionEquation.finiteSlope(slope: slope, interceptY: intcptY)
    }

    fileprivate func updateCurrentData(_ observation: Observation<BFPType>,
                                       indexToRemove: Int?)
    {
        let newIndex = currentData.index + 1

        var newObservations = currentData.observations
        if adding
        { newObservations += [observation] }
        else
        { newObservations.remove(at: indexToRemove!) }

        currentData = try! RegressionData(
            index: newIndex,
            observations: newObservations,
            sumOneOverVarianceY: newSumOne,
            sumXoverVarianceY: newSumX,
            sumYoverVarianceY: newSumY,
            sumXYoverVarianceY: newSumXY,
            sumXsquaredOverVarianceY: newSumXsq,
            sumYsquaredOverVarianceY: newSumYsq,
            meanTotalSquaredError: newMeanTotalSE,
            meanSquaredResidualError: newMeanResidualSE,
            meanSquaredRegressionError: newMeanRegressionSE,
            rSquared: newRsquared,
            equation: newEquation
        )
    }
}

