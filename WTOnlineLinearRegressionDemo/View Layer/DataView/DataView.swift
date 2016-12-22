//
//  DataView.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import UIKit


protocol DataViewDelegate: class
{
    func processTap(in view: UIView,
                    with recogniser: UITapGestureRecognizer)

    func processLongPress(in view: UIView,
                          with recogniser: UILongPressGestureRecognizer)

    func processDrag(in view: UIView,
                     with recogniser: UIPanGestureRecognizer)

    func processPinch(in view: UIView,
                      with recogniser: UIPinchGestureRecognizer)
}

// MARK: -

class DataView: UIView
{
    // MARK: - @IBOutlets
    
    @IBOutlet weak var longPressRecogniser: UILongPressGestureRecognizer!
    @IBOutlet weak var pinchRecogniser: UIPinchGestureRecognizer!
    @IBOutlet weak var dragRecogniser: UIPanGestureRecognizer!
    @IBOutlet weak var tapRecogniser: UITapGestureRecognizer!

    // MARK: - Visible API

    weak var delegate: DataViewDelegate?

    func update(with viewModel: DataViewModel)
    {
        self.viewModel = viewModel
        setNeedsDisplay()
    }
    
    // MARK: - Private properties
    
    fileprivate var viewModel: DataViewModel?
}

// MARK: - Drawing

extension DataView
{
    override func draw(_ rect: CGRect)
    {
        guard let vm = viewModel else { return }
        guard vm.items.count > 0 else { return }

        if let lineEq = vm.lineEquation
        {
            drawUncertaintyArea(lineEq)
            drawRegressionLine(lineEq)
        }

        for item in vm.items
        { draw(item) }

        if let selectedItem = vm.selectedItem
        { draw(selectedItem, selected: true) }
    }

    fileprivate func draw(_ item: DisplayableItem, selected: Bool = false)
    {
        // We subtract the item's y value from center.y because the y axis on
        // iOS runs in the opposite direction as the y axis on regular
        // analytical geometry.

        let center = self.centerInSelfCoordinates
        let x = center.x + item.center.x
        let y = center.y - item.center.y
        let dy = item.dy

        let size = DataViewModel.fillSize + DataViewModel.edgeSize

        if dy > size
        { drawErrorBar(for: item, x: x, y: y, width: size) }

        drawBlobAt(x: x, y: y, selected: selected)
    }

    fileprivate func drawErrorBar(for item: DisplayableItem,
                                  x: CGFloat, y: CGFloat,
                                  width: CGFloat)
    {
        let ymin = y - item.dy
        let ymax = y + item.dy

        let path = UIBezierPath()
        path.lineWidth = DataViewModel.dyLineWidth
        DataViewModel.edgeColor.setStroke()

        path.move(to: CGPoint(x: x - width/2, y: ymin))
        path.addLine(to: CGPoint(x: x + width/2, y: ymin))
        path.stroke()

        path.move(to: CGPoint(x: x - width/2, y: ymax))
        path.addLine(to: CGPoint(x: x + width/2, y: ymax))
        path.stroke()

        path.move(to: CGPoint(x: x, y: ymin))
        path.addLine(to: CGPoint(x: x, y: ymax))
        path.stroke()
    }

    fileprivate func drawBlobAt(x: CGFloat, y: CGFloat, selected: Bool)
    {
        var size = DataViewModel.fillSize + DataViewModel.edgeSize
        var r = CGRect(x: x - size/2, y: y - size/2, width: size, height: size)
        var path = UIBezierPath(ovalIn: r)

        if selected
        { DataViewModel.edgeColorSelected.setFill() }
        else
        { DataViewModel.edgeColor.setFill() }

        path.fill()

        size = DataViewModel.fillSize
        r = CGRect(x: x - size/2, y: y - size/2, width: size, height: size)
        path = UIBezierPath(ovalIn: r)

        if selected
        { DataViewModel.fillColorSelected.setFill() }
        else
        { DataViewModel.fillColor.setFill() }
        
        path.fill()
    }

    fileprivate func drawUncertaintyArea(_ lineEq: LinRegEquation)
    {
        guard lineEq.hasFiniteSlope else { return }

        let slope = lineEq.slope!
        let interceptY = lineEq.interceptY!

        let dm = slope.standardDeviation
        let db = interceptY.standardDeviation

        guard dm != 0 || db != 0 else { return }

        let m = slope.value
        let b = interceptY.value

        let xmin: CGFloat = 0
        let ymin1 = applyRegression(x: xmin, m: m+dm, b: b+db)
        let ymin2 = applyRegression(x: xmin, m: m+dm, b: b-db)
        let ymin3 = applyRegression(x: xmin, m: m-dm, b: b+db)
        let ymin4 = applyRegression(x: xmin, m: m-dm, b: b-db)

        // We apply max to get the low value and min to get the
        // high value because the y axis on iOS runs in the opposite
        // direction as the y axis on regular analytical geometry.
        let yminlo = max(ymin1, ymin2, ymin3, ymin4)
        let yminhi = min(ymin1, ymin2, ymin3, ymin4)

        let xmax: CGFloat = self.bounds.size.width
        let ymax1 = applyRegression(x: xmax, m: m+dm, b: b+db)
        let ymax2 = applyRegression(x: xmax, m: m+dm, b: b-db)
        let ymax3 = applyRegression(x: xmax, m: m-dm, b: b+db)
        let ymax4 = applyRegression(x: xmax, m: m-dm, b: b-db)

        // We apply max to get the low value and min to get the
        // high value because the y axis on iOS runs in the opposite
        // direction as the y axis on regular analytical geometry.
        let ymaxlo = max(ymax1, ymax2, ymax3, ymax4)
        let ymaxhi = min(ymax1, ymax2, ymax3, ymax4)

        let xc = center.x
        let yclo = applyRegression(x: xc, m: m, b: b-db)
        let ychi = applyRegression(x: xc, m: m, b: b+db)

        let path = UIBezierPath()
        path.lineWidth = DataViewModel.regressionLineWidth
        let color = DataViewModel.regressionLineColor.withAlphaComponent(0.25)
        color.setFill()

        path.move(to: CGPoint(x: xmin, y: yminlo))
        path.addLine(to: CGPoint(x: xc, y: yclo))
        path.addLine(to: CGPoint(x: xmax, y: ymaxlo))
        path.addLine(to: CGPoint(x: xmax, y: ymaxhi))
        path.addLine(to: CGPoint(x: xc, y: ychi))
        path.addLine(to: CGPoint(x: xmin, y: yminhi))
        path.addLine(to: CGPoint(x: xmin, y: yminlo))
        path.fill()
    }

    fileprivate func drawRegressionLine(_ lineEq: LinRegEquation)
    {
        if lineEq.hasFiniteSlope
        { drawFiniteSlopeLine(lineEq) }
        else if let x = lineEq.interceptX
        { drawInfiniteSlopeLine(at: x) }
    }

    fileprivate func drawFiniteSlopeLine(_ lineEq: LinRegEquation)
    {
        let m = lineEq.slope!.value
        let b = lineEq.interceptY!.value

        let xmin: CGFloat = 0
        let ymin = applyRegression(x: xmin, m: m, b: b)

        let xmax: CGFloat = self.bounds.size.width
        let ymax = applyRegression(x: xmax, m: m, b: b)

        let path = UIBezierPath()
        path.lineWidth = DataViewModel.regressionLineWidth
        DataViewModel.regressionLineColor.setStroke()

        path.move(to: CGPoint(x: xmin, y: ymin))
        path.addLine(to: CGPoint(x: xmax, y: ymax))
        path.stroke()
    }

    fileprivate func drawInfiniteSlopeLine(at x: CGFloat)
    {
        let center = self.centerInSelfCoordinates
        let x0 = x + center.x

        let ymin: CGFloat = 0
        let ymax: CGFloat = 2 * center.y

        let path = UIBezierPath()
        path.lineWidth = DataViewModel.regressionLineWidth
        DataViewModel.regressionLineColor.setStroke()

        path.move(to: CGPoint(x: x0, y: ymin))
        path.addLine(to: CGPoint(x: x0, y: ymax))
        path.stroke()
    }

    fileprivate func applyRegression(x: CGFloat, m: CGFloat, b: CGFloat) -> CGFloat
    {
        // We subtract the computed y value from center.y because the y axis on
        // iOS runs in the opposite direction as the y axis on regular
        // analytical geometry.

        let center = self.centerInSelfCoordinates
        return center.y - (m * (x - center.x) + b)
    }
}

// MARK: - Tapping

extension DataView
{
    @IBAction func tapAction()
    { delegate?.processTap(in: self, with: tapRecogniser) }
}

// MARK: - Long-pressing

extension DataView
{
    @IBAction func longPressAction()
    { delegate?.processLongPress(in: self, with: longPressRecogniser) }
}

// MARK: - Dragging

extension DataView
{
    @IBAction func dragAction()
    { delegate?.processDrag(in: self, with: dragRecogniser) }
}

// MARK: - Pinching

extension DataView
{
    @IBAction func pinchAction()
    { delegate?.processPinch(in: self, with: pinchRecogniser) }
}

