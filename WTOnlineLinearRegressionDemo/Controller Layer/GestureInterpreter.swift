//
//  GestureInterpreter.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import UIKit
import WTOnlineLinearRegression


protocol GestureInterpreterDelegate: class
{
    func itemsDidChange(to items: [DisplayableItem],
                        lineEquation: LinRegEquation?)

    func itemsDidChange(to items: [DisplayableItem],
                        byAdding item: DisplayableItem,
                        lineEquation: LinRegEquation?)

    func itemsDidChange(to items: [DisplayableItem],
                        byRemoving item: DisplayableItem?,
                        lineEquation: LinRegEquation?)

    func itemsDidChange(to items: [DisplayableItem],
                        bySelecting item: DisplayableItem?,
                        lineEquation: LinRegEquation?)
}

// MARK: -

class GestureInterpreter
{
    // MARK: - Visible API
    
    weak var delegate: GestureInterpreterDelegate?

    init(tapTolerance: CGFloat)
    {
        self.statsEngine = StatisticsEngine(tapTolerance: tapTolerance)
        statsEngine.delegate = self
    }

    func processTapInClearButton()
    { statsEngine.removeAllObservations() }

    // MARK: - Private properties

    fileprivate let statsEngine: StatisticsEngine
    fileprivate var indexOfLastDragAddedPoint: Int?
}

// MARK: - StatisticsEngineDelegate

extension GestureInterpreter: StatisticsEngineDelegate
{
    func statisticalEngineDidAdd(observation: ObservationType)
    {
        let lineEq = lineEquation()
        let observations = statsEngine.observations

        delegate?.itemsDidChange(to: observations,
                                 byAdding: observation,
                                 lineEquation: lineEq)
    }

    func statisticalEngineDidRemove(observation: ObservationType)
    {
        let lineEq = lineEquation()
        let observations = statsEngine.observations

        delegate?.itemsDidChange(to: observations,
                                 byRemoving: observation,
                                 lineEquation: lineEq)
    }

    func statisticalEngineDidSelect(observation: ObservationType?)
    {
        let lineEq = lineEquation()
        let observations = statsEngine.observations

        delegate?.itemsDidChange(to: observations,
                                 bySelecting: observation,
                                 lineEquation: lineEq)
    }

    func statisticalEngineDidRemoveAllObservations()
    {
        let lineEq = lineEquation()
        let observations = statsEngine.observations

        delegate?.itemsDidChange(to: observations,
                                 lineEquation: lineEq)
    }
}

// MARK: - Tapping

extension GestureInterpreter
{
    func processTap(in view: UIView, with recogniser: UITapGestureRecognizer)
    {
        if recogniser.state == .ended
        {
            let tapPoint = tapLocation(in: view, with: recogniser)
            
            if let index = statsEngine.indexOfObservationNearest(to: tapPoint)
            { statsEngine.selectObservation(at: index) }
            else
            {
                let obs = observation(for: tapPoint)
                statsEngine.addObservation(obs)
            }
        }
    }
}

// MARK: - Long-pressing

extension GestureInterpreter
{
    func processLongPress(in view: UIView, with recogniser: UILongPressGestureRecognizer)
    {
        let tapPoint = tapLocation(in: view, with: recogniser)
        guard let index = statsEngine.indexOfObservationNearest(to: tapPoint) else { return }

        switch recogniser.state
        {
        case .began:
            if !statsEngine.isObservationSelected(at: index)
            { statsEngine.selectObservation(at: index) }
        case .ended:
            statsEngine.removeObservation(at: index)
        default:
            break
        }
    }
}

// MARK: - Dragging

extension GestureInterpreter
{
    func processDrag(in view: UIView, with recogniser: UIPanGestureRecognizer)
    {
        let tapPoint = tapLocation(in: view, with: recogniser)

        switch recogniser.state
        {
        case .began:
            indexOfLastDragAddedPoint =
                statsEngine.indexOfObservationNearest(to: tapPoint)
        case .changed:
            addNewDragAddedObservation(at: tapPoint)
        case .ended:
            indexOfLastDragAddedPoint = nil
        default:
            break
        }
    }
}

// MARK: - Pinching

extension GestureInterpreter
{
    func processPinch(in view: UIView, with recogniser: UIPinchGestureRecognizer)
    {
        if recogniser.state == .changed
        { statsEngine.updateSelection(with: recogniser.scale) }
    }
}

// MARK: - Private API

extension GestureInterpreter
{
    fileprivate func tapLocation(in view: UIView,
                                 with gr: UIGestureRecognizer) -> CGPoint
    {
        let center = view.centerInSelfCoordinates
        let cx = center.x
        let cy = center.y

        // We subtract the point's y value from center.y because the y axis on
        // iOS runs in the opposite direction as the y axis on regular
        // analytical geometry.

        let tapPoint = gr.location(in: view)
        let localTapPoint = CGPoint(x: tapPoint.x - cx, y: cy - tapPoint.y)

        return localTapPoint
    }

    fileprivate func observation(for point: CGPoint) -> ObservationType
    { return ObservationType(x: point.x, y: point.y) }

    fileprivate func lineEquation() -> LinRegEquation?
    { return statsEngine.linearRegresser.currentData.equation }

    fileprivate func addNewDragAddedObservation(at point: CGPoint)
    {
        var lastObs: ObservationType? = nil
        if let indexOfLastAdded = indexOfLastDragAddedPoint
        {
            lastObs = statsEngine.observations[indexOfLastAdded]
            statsEngine.removeObservation(at: indexOfLastAdded)
            indexOfLastDragAddedPoint = nil
        }

        let index = statsEngine.indexOfObservationNearest(to: point)

        guard index == nil else {
            let lineEq = lineEquation()
            let items = statsEngine.observations
            let item = items[index!]
            delegate?.itemsDidChange(to: items, bySelecting: item, lineEquation: lineEq)
            return
        }

        var obs = observation(for: point)
        if let lastObs = lastObs { obs = obs.with(dy: lastObs.dy) }

        statsEngine.addObservation(obs)
        indexOfLastDragAddedPoint = statsEngine.observations.count - 1
    }
}

