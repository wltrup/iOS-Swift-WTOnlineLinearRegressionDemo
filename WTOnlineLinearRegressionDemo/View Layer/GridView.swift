//
//  GridView.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import UIKit


fileprivate struct GridParams
{
    let gap: CGFloat   // gap between successive tick centers
    let lineW: CGFloat // tick width
    let color: UIColor
}

// MARK: -

class GridView: UIView
{
    // MARK: - Visible API

    override func draw(_ rect: CGRect)
    {
        drawGrid(GridView.minorGridParams, rect: rect)
        drawGrid(GridView.majorGridParams, rect: rect)
        drawAxes(rect)
    }
    
    // MARK: - Private properties

    fileprivate static let minorGridParams =
        GridParams(gap: 15, lineW: 1, color: .lightGray)

    fileprivate static let majorGridParams =
        GridParams(gap: 60, lineW: 2, color: .gray)

    fileprivate let axisW: CGFloat = 3
    fileprivate let axisColor = UIColor.red
}

// MARK: - Private API

extension GridView
{
    fileprivate func drawGrid(_ params: GridParams, rect: CGRect)
    {
        let center = self.centerInSelfCoordinates
        let cx = center.x
        let cy = center.y

        let dx: CGFloat = params.gap
        let (xmin, xmax, nminX, nmaxX) =
            computeLoopParams(ds: dx, cs: cx,
                              sorigin: rect.origin.x, slength: rect.size.width)

        let dy = dx
        let (ymin, ymax, nminY, nmaxY) =
            computeLoopParams(ds: dy, cs: cy,
                              sorigin: rect.origin.y, slength: rect.size.height)

        let start = CGPoint(x: xmin, y: ymin)
        let   end = CGPoint(x: xmax, y: ymax)

        drawLines(isX: true, nmin: nminX, nmax: nmaxX, ds: dx,
                  center: center, start: start, end: end, gridParams: params)

        drawLines(isX: false, nmin: nminY, nmax: nmaxY, ds: dy,
                  center: center, start: start, end: end, gridParams: params)
    }

    fileprivate func drawAxes(_ rect: CGRect)
    {
        let center = self.centerInSelfCoordinates
        let cx = center.x
        let cy = center.y

        let xmin = rect.origin.x - cx
        let xmax = xmin + rect.size.width

        let ymin = rect.origin.y - cy
        let ymax = ymin + rect.size.height

        let start = CGPoint(x: xmin, y: ymin)
        let   end = CGPoint(x: xmax, y: ymax)

        drawAxis(isX: true,  center: center, start: start, end: end)
        drawAxis(isX: false, center: center, start: start, end: end)
    }

    fileprivate func computeLoopParams(ds: CGFloat, cs: CGFloat,
                                       sorigin: CGFloat, slength: CGFloat)
        -> (smin: CGFloat, smax: CGFloat, nmin: Int, nmax: Int)
    {
        let smin = sorigin - cs
        let nmin = Int(ceil(smin/ds))

        let smax = smin + slength
        let nmax = Int(floor(smax/ds))

        return (smin, smax, nmin, nmax)
    }

    fileprivate func drawLines(isX: Bool, nmin: Int, nmax: Int, ds: CGFloat,
                               center: CGPoint, start: CGPoint, end: CGPoint,
                               gridParams: GridParams)
    {
        if nmin <= nmax
        {
            let cx = center.x
            let cy = center.y

            for n in nmin...nmax
            {
                let path = UIBezierPath()
                if isX
                {
                    let s = CGFloat(n)*ds + cx
                    let y1 = start.y + cy
                    let y2 = end.y + cy
                    path.move(to: CGPoint(x: s, y: y1))
                    path.addLine(to: CGPoint(x: s, y: y2))
                }
                else
                {
                    let x1 = start.x + cx
                    let x2 = end.x + cx
                    let s = CGFloat(n)*ds + cy
                    path.move(to: CGPoint(x: x1, y: s))
                    path.addLine(to: CGPoint(x: x2, y: s))
                }
                path.lineWidth = gridParams.lineW
                gridParams.color.setStroke()
                path.stroke()
            }
        }
    }

    fileprivate func drawAxis(isX: Bool, center: CGPoint, start: CGPoint, end: CGPoint)
    {
        let cx = center.x
        let cy = center.y

        let path = UIBezierPath()
        if isX
        {
            let y1 = start.y + cy
            let y2 = end.y + cy
            path.move(to: CGPoint(x: cx, y: y1))
            path.addLine(to: CGPoint(x: cx, y: y2))
        }
        else
        {
            let x1 = start.x + cx
            let x2 = end.x + cx
            path.move(to: CGPoint(x: x1, y: cy))
            path.addLine(to: CGPoint(x: x2, y: cy))
        }
        path.lineWidth = axisW
        axisColor.setStroke()
        path.stroke()
    }
}

