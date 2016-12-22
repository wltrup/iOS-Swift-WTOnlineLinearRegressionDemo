//
//  UIView+extension.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import UIKit


extension UIView
{
    var centerInSelfCoordinates: CGPoint
    {
        let w = self.bounds.width
        let h = self.bounds.height

        let cx: CGFloat = w / 2
        let cy: CGFloat = h / 2

        return CGPoint(x: cx, y: cy)
    }
}
