//
//  LinearInterpolation.swift
//  PixelAnimGenerator
//
//  Created by Charlie Williams on 24/06/2018.
//  Copyright © 2018 Charlie Williams. All rights reserved.
//

import UIKit

extension Int {

    func lerp(from: Int, to: Int, out1: CGFloat, out2: CGFloat, clamp: Bool = true) -> CGFloat {
        return CGFloat(self).lerp(from: CGFloat(from), to: CGFloat(to), out1: out1, out2: out2, clamp: clamp)
    }
}

extension FloatingPoint {

    func lerp(from: Self, to: Self, out1: Self, out2: Self, clamp: Bool = true) -> Self {

        let dist = to - from
        let pct = self / dist
        let toDist = out2 - out1

        let lerped = pct * toDist + out1

        if clamp {
            let _max = max(out1, out2)
            let _min = min(out1, out2)
            return lerped > _max ? _max : lerped < _min ? _min : lerped
        } else {
            return lerped
        }
    }
}
