//
//  String+Extensions.swift
//
//  https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language/38215613#38215613
//  Copyright © 2020 Leo Dabus. All rights reserved.
//

import Foundation

public extension StringProtocol {

    subscript(_ offset: Int) -> Element {
        self[index(startIndex, offsetBy: offset)]
    }

    subscript(_ range: Range<Int>) -> SubSequence {
        prefix(range.lowerBound + range.count).suffix(range.count)
    }

    subscript(_ range: ClosedRange<Int>) -> SubSequence {
        prefix(range.lowerBound + range.count).suffix(range.count)
    }

    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence {
        prefix(range.upperBound.advanced(by: 1))
    }

    subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence {
        prefix(range.upperBound)
    }

    subscript(_ range: PartialRangeFrom<Int>) -> SubSequence {
        suffix(Swift.max(0, count - range.lowerBound))
    }
}

public extension LosslessStringConvertible {

    var string: String {
        .init(self)
    }
}

public extension BidirectionalCollection {

    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else {
            return nil
        }
        return self[i]
    }
}
