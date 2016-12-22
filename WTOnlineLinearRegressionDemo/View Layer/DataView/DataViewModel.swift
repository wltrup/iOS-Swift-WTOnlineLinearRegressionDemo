//
//  DataViewModel.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import UIKit


struct DataViewModel
{
    // MARK: - Visible API

    let items: [DisplayableItem]
    let lineEquation: LinRegEquation?
    let selectedItem: DisplayableItem?

    // MARK: -

    static let fillSize: CGFloat = 12
    static let edgeSize: CGFloat = 5

    static let fillColor = UIColor.green
    static let edgeColor = UIColor.black

    static let fillColorSelected = UIColor.yellow
    static let edgeColorSelected = UIColor.black

    static let dyLineWidth: CGFloat = 2

    static let regressionLineWidth: CGFloat = 3
    static let regressionLineColor = UIColor.blue

    // MARK: -
    
    init(items: [DisplayableItem],
         lineEquation: LinRegEquation? = nil,
         selecting item: DisplayableItem? = nil)
    {
        self.items = items
        self.lineEquation = lineEquation
        self.selectedItem = item
    }
}

