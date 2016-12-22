//
//  ViewController.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import UIKit


class ViewController: UIViewController
{
    // MARK: - @IBOutlets

    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var dataView: DataView!
    @IBOutlet weak var infoView: InfoView!

    // MARK: - Visible API

    override func viewDidLoad()
    {
        super.viewDidLoad()

        dataView!.delegate = self

        let tapTolerance = DataViewModel.fillSize + DataViewModel.edgeSize
        gestureInterpreter = GestureInterpreter(tapTolerance: tapTolerance)
        gestureInterpreter.delegate = self
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)

        gridView.setNeedsDisplay()
        dataView.setNeedsDisplay()
        infoView.setNeedsDisplay()
    }

    // MARK: - Private properties

    fileprivate var gestureInterpreter: GestureInterpreter!
}

// MARK: - InfoView actions

extension ViewController
{
    @IBAction func clearAction()
    { gestureInterpreter.processTapInClearButton() }
}

// MARK: - DataViewDelegate

extension ViewController: DataViewDelegate
{
    func processTap(in view: UIView, with recogniser: UITapGestureRecognizer)
    { gestureInterpreter.processTap(in: view, with: recogniser) }

    func processLongPress(in view: UIView, with recogniser: UILongPressGestureRecognizer)
    { gestureInterpreter.processLongPress(in: view, with: recogniser) }

    func processDrag(in view: UIView, with recogniser: UIPanGestureRecognizer)
    { gestureInterpreter.processDrag(in: view, with: recogniser) }

    func processPinch(in view: UIView, with recogniser: UIPinchGestureRecognizer)
    { gestureInterpreter.processPinch(in: view, with: recogniser) }
}

// MARK: - GestureInterpreterDelegate

extension ViewController: GestureInterpreterDelegate
{
    func itemsDidChange(to items: [DisplayableItem],
                        lineEquation: LinRegEquation?)
    {
        let dataVM = DataViewModel(items: items,
                                   lineEquation: lineEquation)
        dataView.update(with: dataVM)

        let infoVM = InfoViewModel(numberOfItems: items.count,
                                   lineEquation: lineEquation)
        infoView.update(with: infoVM)
    }
    
    func itemsDidChange(to items: [DisplayableItem],
                        bySelecting item: DisplayableItem?,
                        lineEquation: LinRegEquation?)
    {
        let dataVM = DataViewModel(items: items,
                                   lineEquation: lineEquation,
                                   selecting: item)
        dataView.update(with: dataVM)

        let infoVM = InfoViewModel(numberOfItems: items.count,
                                   lineEquation: lineEquation,
                                   item: item)
        infoView.update(with: infoVM)
    }
    
    func itemsDidChange(to items: [DisplayableItem],
                        byAdding item: DisplayableItem,
                        lineEquation: LinRegEquation?)
    {
        let dataVM = DataViewModel(items: items,
                                   lineEquation: lineEquation,
                                   selecting: item)
        dataView.update(with: dataVM)

        let infoVM = InfoViewModel(numberOfItems: items.count,
                                   lineEquation: lineEquation,
                                   item: item)
        infoView.update(with: infoVM)
    }

    func itemsDidChange(to items: [DisplayableItem],
                        byRemoving item: DisplayableItem?,
                        lineEquation: LinRegEquation?)
    {
        let dataVM = DataViewModel(items: items,
                                   lineEquation: lineEquation)
        dataView.update(with: dataVM)

        let infoVM = InfoViewModel(numberOfItems: items.count,
                                   lineEquation: lineEquation)
        infoView.update(with: infoVM)
    }
}

