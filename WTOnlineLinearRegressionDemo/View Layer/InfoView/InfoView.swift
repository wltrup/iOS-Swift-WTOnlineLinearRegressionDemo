//
//  InfoView.swift
//  WTOnlineLinearRegressionDemo
//
//  Created by Wagner Truppel on 09/12/2016.
//  Copyright © 2016 wtruppel. All rights reserved.
//

import UIKit


class InfoView: UIView
{
    // MARK: - @IBOutlets

    @IBOutlet weak var numObservationsLabel: UILabel!
    @IBOutlet weak var     observationLabel: UILabel!
    @IBOutlet weak var          lineEqLabel: UILabel!

    // MARK: - Visible API

    func update(with viewModel: InfoViewModel)
    {
        numObservationsLabel.text = viewModel.numberOfItemsString()
        observationLabel.text = viewModel.itemString()
        lineEqLabel.text = viewModel.lineEqString()
    }
}

