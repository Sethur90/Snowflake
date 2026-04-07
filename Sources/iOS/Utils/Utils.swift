import UIKit

struct Utils {

    static func number(string: String) -> CGFloat {
        let scanner = Scanner(string: string)
        return scanner.scanFloat().map { CGFloat($0) } ?? 0
    }

    static func numbers(string: String?) -> [CGFloat] {
        guard let string = string else { return [] }

        let scanner = Scanner(string: string)
        var numbers = [CGFloat]()

        while !scanner.isAtEnd {
            if let value = scanner.scanFloat() {
                numbers.append(CGFloat(value))
            } else if !scanner.isAtEnd {
                scanner.currentIndex = string.index(after: scanner.currentIndex)
            }
        }

        return numbers
    }

    static func isLowercase(string: String) -> Bool {
        guard let scalar = UnicodeScalar(string) else { return false }
        return CharacterSet.lowercaseLetters.contains(scalar)
    }

    static func points(string: String?) -> [CGPoint] {
        var numbers = self.numbers(string: string)
        if numbers.count % 2 == 1 {
            numbers.append(0)
        }

        var points = [CGPoint]()
        numbers.enumerated().forEach { index, _ in
            if index % 2 == 0 {
                points.append(CGPoint(x: numbers[index], y: numbers[index + 1]))
            }
        }

        return points
    }

    // MARK: - Ratio

    static func ratio(from: CGSize, to: CGSize) -> CGFloat {
        return min(to.width / from.width, to.height / from.height)
    }

    // MARK: - Bounds

    static func bounds(layers: [CALayer]) -> CGRect {
        let paths: [CGPath] = layers.compactMap {
            ($0 as? CAShapeLayer)?.path
        }
        return bounds(paths: paths)
    }

    static func bounds(paths: [CGPath]) -> CGRect {
        var rect = CGRect.zero
        paths.forEach { path in
            rect = path.boundingBox.union(rect)
        }
        return rect
    }

    static func transform(layers: [CALayer], transform: CGAffineTransform) {
        for layer in layers {
            if let layer = layer as? CAShapeLayer, let cgPath = layer.path {
                let path = UIBezierPath(cgPath: cgPath)
                path.apply(transform)
                layer.path = path.cgPath
            }
        }
    }
}
