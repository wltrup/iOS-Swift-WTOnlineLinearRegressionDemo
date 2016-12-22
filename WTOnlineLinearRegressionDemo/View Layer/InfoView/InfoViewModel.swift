//
//  InfoViewModel.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import UIKit


struct InfoViewModel
{
    // MARK: - Visible API

    init(numberOfItems: Int,
         lineEquation: LinRegEquation? = nil,
         item: DisplayableItem? = nil)
    {
        self.numberOfItems = numberOfItems
        self.item = item
        self.lineEquation = lineEquation
    }

    // MARK: -
    
    func numberOfItemsString() -> String
    { return "# points: \(numberOfItems)" }

    func itemString() -> String?
    {
        guard let item = item else { return nil }

        let  xstr = InfoViewModel.decimalNumberFormatter.string(for: item.center.x)
        let  ystr = InfoViewModel.decimalNumberFormatter.string(for: item.center.y)
        let dystr = InfoViewModel.decimalNumberFormatter.string(for: item.dy)

        if let xstr = xstr, let ystr = ystr, let dystr = dystr
        { return "(\(xstr), \(ystr) ± \(dystr))" }
        else
        { return nil }
    }

    func lineEqString() -> String?
    {
        guard let lineEq = lineEquation else { return nil }

        if lineEq.hasFiniteSlope
        {
            let s = lineEq.slope!.value
            let sstr = InfoViewModel.decimalNumberFormatter.string(for: s)!

            let b = lineEq.interceptY!.value
            let bstr = InfoViewModel.decimalNumberFormatter.string(for: b)!

            let ds = lineEq.slope!.standardDeviation
            let dsstr = InfoViewModel.decimalNumberFormatter.string(for: ds)!

            let db = lineEq.interceptY!.standardDeviation
            let dbstr = InfoViewModel.decimalNumberFormatter.string(for: db)!

            return "y = (\(sstr) ± \(dsstr))*x + (\(bstr) ± \(dbstr))"
        }
        else if let intcptX = lineEq.interceptX
        {
            let intcptXstr = InfoViewModel.decimalNumberFormatter.string(for: intcptX)!
            return "x = \(intcptXstr)"
        }
        else
        { return nil }
    }

    // MARK: - Private properties

    fileprivate let numberOfItems: Int
    fileprivate let item: DisplayableItem?
    fileprivate let lineEquation: LinRegEquation?

    fileprivate static var decimalNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
}

