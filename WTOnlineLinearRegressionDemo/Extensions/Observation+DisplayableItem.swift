//
//  Observation+DisplayableItem.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import WTOnlineLinearRegression


struct ObservationType: Equatable
{
    var x: CGFloat { return obs.x }
    var y: CGFloat { return obs.y.value }
    var dy: CGFloat { return obs.y.standardDeviation }
    var yHasVariance: Bool { return dy != 0 }

    let obs: Observation<CGFloat>

    init(x: Int, y: Int, dy: CGFloat = 0)
    { self.init(x: CGFloat(x), y: CGFloat(y), dy: dy) }

    init(x: Int, y: CGFloat, dy: CGFloat)
    { self.init(x: CGFloat(x), y: y, dy: dy) }

    init(x: CGFloat, y: Int, dy: CGFloat)
    { self.init(x: x, y: CGFloat(y), dy: dy) }

    init(x: CGFloat, y: CGFloat, dy: CGFloat = 0)
    { try! self.obs = Observation<CGFloat>(x: x, y: y, yStandardDeviation: dy) }

    func with(dy: CGFloat) -> ObservationType
    { return ObservationType(x: self.x, y: self.y, dy: dy) }

    static func ==(lhs: ObservationType, rhs: ObservationType) -> Bool
    { return lhs.obs == rhs.obs }
}


extension ObservationType: DisplayableItem
{
    var center: CGPoint
    { return CGPoint(x: self.x, y: self.y) }
}

