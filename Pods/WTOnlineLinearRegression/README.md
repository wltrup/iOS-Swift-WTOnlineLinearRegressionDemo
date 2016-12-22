# WTOnlineLinearRegression

[![CI Status](http://img.shields.io/travis/wltrup/Swift-WTOnlineLinearRegression.svg?style=flat)](https://travis-ci.org/wltrup/Swift-WTOnlineLinearRegression)
[![Version](https://img.shields.io/cocoapods/v/WTOnlineLinearRegression.svg?style=flat)](http://cocoapods.org/pods/WTOnlineLinearRegression)
[![License](https://img.shields.io/cocoapods/l/WTOnlineLinearRegression.svg?style=flat)](http://cocoapods.org/pods/WTOnlineLinearRegression)
[![Platform](https://img.shields.io/cocoapods/p/WTOnlineLinearRegression.svg?style=flat)](http://cocoapods.org/pods/WTOnlineLinearRegression)
[![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-8.2-blue.svg)](https://developer.apple.com/xcode)

## What

**WTOnlineLinearRegression** allows you to perform *linear* regression on one-dimensional
data, with or without uncertainties in the dependent quantity, and it does so by updating
its internal state in constant time on the number of data points, for each new data point.
In other words, it performs **online** regression, updating its internal state without
recomputing everything from scratch (which would use the entire data set) every time a new
data point is added.

You can also *remove* data points that have been previously added to the data set.
Removing, however, runs in linear time on the size of the data set since it must scan it
to guarantee that the data point being removed was once added.

Additionally, **WTOnlineLinearRegression** optionally keeps a history of every data point
addition or removal, as full snapshots of the regression at the time the data points were
added or removed.

## Usage ##

An `Observation` instance represents a pair of values `(x,y)` where the dependent value,
`y`, may also have some uncertainty associated with it, in the form of its *variance* (or,
equivalently, its *standard deviation*).

Given a series of `N` such observations, `{(xi, yi, dyi), 1 ≤ i ≤ N}`, one might be
interested in finding the straight line `y = a * x + b` that best fits those observations.
That's the task of the `LinearRegression` object and since it's possible that the `y`
values in the actual observations could be uncertain, the estimated slope `a` and the
estimated intercept `b` will, themselves, have some uncertainty.

In other words, the best line that fits the series of observations will have an equation
of the form `y = (a ± da) * x + (b ± db)`, where I'm using `d•` to refer to the standard
deviation of the quantity in front of it.

`LinearRegression` performs the regression and computes the *slope* `a ± da`, the
*Y-intercept* `b ± db`, three measures of error (*mean total squared error*, *mean squared
residual error*, and *mean squared regression error*), and the coefficient of fitness
known as *r-squared*. You may also inspect various sums that are used to compute those
quantities.

You may also optionally request `LinearRegression` to record the history of changes, as
data points are added or removed from the data set. Each entry in the history is a full
snapshot of the regression at the time the entry was processed.

## Documentation ##

Full documentation is provided in the source files. Additionally, the main mathematical
results used to implement `WTOnlineLinearRegression` are available in a pdf document
[here](https://github.com/wltrup/Swift-WTOnlineLinearRegression/blob/master/WTOnlineLinearRegression.pdf).

## Demo app ##

Check out the [demo app](https://github.com/wltrup/iOS-Swift-WTOnlineLinearRegressionDemo).

## Tests ##

**WTOnlineLinearRegression** is verified by **134 tests**, with **100% coverage**.

## Changelog ##

Changes to **WTOnlineLinearRegression** are listed
[here](https://github.com/wltrup/Swift-WTOnlineLinearRegression/blob/master/CHANGELOG.md).

## Installation ##

**WTOnlineLinearRegression** is available through [CocoaPods](http://cocoapods.org). To
install it, simply add the following line to your Podfile:

```ruby pod "WTOnlineLinearRegression" ```

## Author ##

Wagner Truppel, trupwl@gmail.com

## License ##

**WTOnlineLinearRegression** is available under the MIT license. See the LICENSE file for
more info.
