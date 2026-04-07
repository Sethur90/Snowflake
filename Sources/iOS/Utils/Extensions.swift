import CoreGraphics
import Foundation
import UIKit

extension Dictionary where Key == String, Value == String {

    func number(key: String) -> CGFloat? {
        guard let value = self[key] else { return nil }
        return Utils.number(string: value)
    }

    func string(key: String) -> String? {
        return self[key]
    }

    func color(key: String) -> UIColor? {
        guard let value = self[key] else { return nil }
        return Color.color(name: value)
    }

    func merge(another: [String: String]) -> [String: String] {
        var result = self
        another.forEach { result[$0] = $1 }
        return result
    }
}

extension String {

    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
