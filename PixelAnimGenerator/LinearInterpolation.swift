//
//  LinearInterpolation.swift
//  PixelAnimGenerator
//
//  Created by Charlie Williams on 24/06/2018.
//  Copyright © 2018 Charlie Williams. All rights reserved.
//

import UIKit

extension Int {

    func lerp(from: Int, to: Int, min: CGFloat, max: CGFloat, clamp: Bool = true) -> CGFloat {
        return CGFloat(self).lerp(from: CGFloat(from), to: CGFloat(to), min: min, max: max, clamp: clamp)
    }
}

extension FloatingPoint {

    func lerp(from: Self, to: Self, min: Self, max: Self, clamp: Bool = true) -> Self {

        let dist = to - from
        let pct = self / dist
        let toDist = max - min

        let lerped = pct * toDist + min

        if clamp {
            return lerped > max ? max : lerped < min ? min : lerped
        } else {
            return lerped
        }
    }
}
