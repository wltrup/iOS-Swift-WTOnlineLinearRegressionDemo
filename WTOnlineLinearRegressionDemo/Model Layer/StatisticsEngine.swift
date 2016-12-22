//
//  StatisticsEngine.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import WTOnlineLinearRegression


protocol StatisticsEngineDelegate: class
{
    func statisticalEngineDidAdd(observation: ObservationType)
    func statisticalEngineDidRemove(observation: ObservationType)
    func statisticalEngineDidSelect(observation: ObservationType?)
    func statisticalEngineDidRemoveAllObservations()
}

// MARK: -

class StatisticsEngine
{
    // MARK: - Visible API

    weak var delegate: StatisticsEngineDelegate?

    init(tapTolerance: CGFloat)
    {
        self.tapTolerance = tapTolerance
        self.linearRegresser =
            try! LinReg(ignoringVarianceInY: StatisticsEngine.ignoreVarInY,
                        minimumVarianceInY: StatisticsEngine.minVarInY,
                        keepingHistory: StatisticsEngine.keepHistory)
    }

    fileprivate(set) var observations: [ObservationType] = []
    fileprivate(set) var linearRegresser: LinReg

    // MARK: -
    
    func indexOfObservationNearest(to point: CGPoint) -> Int?
    {
        guard observations.count > 0 else { return nil }

        for (index, obs) in observations.enumerated()
        {
            guard abs(obs.x - point.x) <= tapTolerance else { continue }

            let tolerance = max(obs.dy, tapTolerance)
            guard abs(obs.y - point.y) <= tolerance else { continue }

            return index
        }

        return nil
    }

    // MARK: -

    func isObservationSelected(at index: Int) -> Bool
    { return currentlySelectedIndex == index }

    func selectObservation(at index: Int)
    {
        let obs: ObservationType?
        if currentlySelectedIndex == index
        {
            currentlySelectedIndex = nil
            obs = nil
        }
        else
        {
            currentlySelectedIndex = index
            obs = observations[index]
        }
        delegate?.statisticalEngineDidSelect(observation: obs)
    }

    func addObservation(_ observation: ObservationType)
    {
        currentlySelectedIndex = observations.count
        observations.append(observation)
        linearRegresser.add(observation.obs)
        delegate?.statisticalEngineDidAdd(observation: observation)
    }

    func removeObservation(at index: Int)
    {
        currentlySelectedIndex = nil
        let observation = observations[index]
        observations.remove(at: index)
        try! linearRegresser.remove(observation.obs)
        delegate?.statisticalEngineDidRemove(observation: observation)
    }

    func removeAllObservations()
    {
        currentlySelectedIndex = nil
        observations = []
        linearRegresser = try! LinReg(ignoringVarianceInY: StatisticsEngine.ignoreVarInY,
                                      minimumVarianceInY: StatisticsEngine.minVarInY,
                                      keepingHistory: StatisticsEngine.keepHistory)
        delegate?.statisticalEngineDidRemoveAllObservations()
    }

    func updateSelection(with scale: CGFloat)
    {
        guard let curSelectedIndex = currentlySelectedIndex else { return }
        let curObs = observations[curSelectedIndex]

        let dy = 10 * scale // XXX
        let newObs = curObs.with(dy: dy)

        removeObservation(at: curSelectedIndex)
        addObservation(newObs)
    }

    // MARK: - Private properties

    fileprivate static let keepHistory = false
    fileprivate static let ignoreVarInY = false
    fileprivate static let minVarInY: CGFloat = 0.1

    fileprivate let tapTolerance: CGFloat
    fileprivate var currentlySelectedIndex: Int?
}

