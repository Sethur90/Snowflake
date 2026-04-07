import CoreGraphics
import Foundation
import UIKit

extension UIBezierPath {
    static func from(svgPath: String) -> UIBezierPath {
        let path = UIBezierPath()

        let commandSet = CharacterSet(charactersIn: Command.letters)
        let scanner = Scanner(string: svgPath)
        var commands: [Command] = []

        while !scanner.isAtEnd {
            // Scan one or more command letters
            guard let initial = scanner.scanCharacters(from: commandSet), !initial.isEmpty else { break }
            // Scan the number string up to the next command letter (may be empty for Z)
            let numbers = scanner.scanUpToCharacters(from: commandSet) ?? ""

            if let command = Command.make(initial: String(initial.last!), string: numbers) {
                commands.append(command)
            }
        }

        commands.enumerated().forEach { index, command in
            let previousCommand: Command? = index > 0 ? commands[index - 1] : nil
            command.act(path: path, previousCommand: previousCommand)
        }

        return path
    }
}

class Command {
    enum Kind {
        case absolute, relative
    }

    let kind: Kind

    required init(string: String, kind: Kind) {
        self.kind = kind
    }

    func act(path: UIBezierPath, previousCommand: Command?) {}
}

extension Command {
    class func make(initial: String, string: String) -> Command? {
        let type: Command.Type? = availableCommands[initial.uppercased()]
        let kind: Kind = SnowflakeUtils.isLowercase(string: initial) ? .relative : .absolute
        return type?.init(string: string, kind: kind)
    }

    static let availableCommands: [String: Command.Type] = [
        "M": MoveToCommand.self,
        "L": LineToCommand.self,
        "H": HorizontalLineToCommand.self,
        "V": VerticalLineToCommand.self,
        "C": CurveToCommand.self,
        "S": SmoothCurveToCommand.self,
        "Q": QuadraticBezierCurveCommand.self,
        "T": SmoothQuadraticBezierCurveToCommand.self,
        "A": EllipticalArcCommand.self,
        "Z": ClosePathCommand.self
    ]

    static var letters: String {
        availableCommands.reduce("") { result, pair in
            result + pair.key + pair.key.lowercased()
        }
    }
}

final class ClosePathCommand: Command {
    convenience init() {
        self.init(string: "", kind: .absolute)
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        path.close()
    }
}

final class CurveToCommand: Command {
    var controlPoint1: CGPoint = .zero
    var controlPoint2: CGPoint = .zero
    var endPoint: CGPoint = .zero

    required init(string: String, kind: Kind) {
        super.init(string: string, kind: kind)

        let numbers = SnowflakeUtils.numbers(string: string)
        if numbers.count >= 6 {
            controlPoint1 = CGPoint(x: numbers[0], y: numbers[1])
            controlPoint2 = CGPoint(x: numbers[2], y: numbers[3])
            endPoint = CGPoint(x: numbers[4], y: numbers[5])
        }
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        if kind == .relative {
            let current = path.currentPoint
            endPoint = current.add(p: endPoint)
            controlPoint1 = current.add(p: controlPoint1)
            controlPoint2 = current.add(p: controlPoint2)
        }
        path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
}

final class EllipticalArcCommand: Command {
    var radius: CGPoint = .zero
    var rotation: CGFloat = 0
    var largeArcFlag: Bool = false
    var sweepFlag: Bool = false
    var endPoint: CGPoint = .zero

    required init(string: String, kind: Kind) {
        super.init(string: string, kind: kind)

        let numbers = SnowflakeUtils.numbers(string: string)
        if numbers.count >= 7 {
            radius = CGPoint(x: numbers[0], y: numbers[1])
            rotation = numbers[2]
            largeArcFlag = numbers[3] > 0
            sweepFlag = numbers[4] > 0
            endPoint = CGPoint(x: numbers[5], y: numbers[6])
        }
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        // Elliptical arc approximation using cubic bezier curves
        let current = path.currentPoint
        let end = kind == .relative ? current.add(p: endPoint) : endPoint

        guard radius.x > 0, radius.y > 0, current != end else {
            path.addLine(to: end)
            return
        }

        // Simplified arc: draw a line to endpoint (full arc support requires complex math)
        path.addLine(to: end)
    }
}

final class HorizontalLineToCommand: Command {
    var x: CGFloat = 0

    required init(string: String, kind: Kind) {
        super.init(string: string, kind: kind)

        let numbers = SnowflakeUtils.numbers(string: string)
        if let first = numbers.first {
            x = first
        }
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        let end: CGPoint
        switch kind {
        case .absolute:
            end = CGPoint(x: x, y: path.currentPoint.y)
        case .relative:
            end = CGPoint(x: path.currentPoint.x + x, y: path.currentPoint.y)
        }
        path.addLine(to: end)
    }
}

final class LineToCommand: Command {
    var point: CGPoint = .zero

    required init(string: String, kind: Kind) {
        super.init(string: string, kind: kind)

        let numbers = SnowflakeUtils.numbers(string: string)
        if numbers.count >= 2 {
            point = CGPoint(x: numbers[0], y: numbers[1])
        }
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        if kind == .relative {
            point = path.currentPoint.add(p: point)
        }
        path.addLine(to: point)
    }
}

final class MoveToCommand: Command {
    var point: CGPoint = .zero

    required init(string: String, kind: Kind) {
        super.init(string: string, kind: kind)

        let numbers = SnowflakeUtils.numbers(string: string)
        if numbers.count >= 2 {
            point = CGPoint(x: numbers[0], y: numbers[1])
        }
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        if kind == .relative {
            point = path.currentPoint.add(p: point)
        }
        path.move(to: point)
    }
}

final class QuadraticBezierCurveCommand: Command {
    var controlPoint: CGPoint = .zero
    var endPoint: CGPoint = .zero

    required init(string: String, kind: Kind) {
        super.init(string: string, kind: kind)

        let numbers = SnowflakeUtils.numbers(string: string)
        if numbers.count >= 4 {
            controlPoint = CGPoint(x: numbers[0], y: numbers[1])
            endPoint = CGPoint(x: numbers[2], y: numbers[3])
        }
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        if kind == .relative {
            let current = path.currentPoint
            endPoint = current.add(p: endPoint)
            controlPoint = current.add(p: controlPoint)
        }
        path.addQuadCurve(to: endPoint, controlPoint: controlPoint)
    }
}

final class SmoothCurveToCommand: Command {
    var controlPoint1: CGPoint = .zero
    var controlPoint2: CGPoint = .zero
    var endPoint: CGPoint = .zero

    required init(string: String, kind: Kind) {
        super.init(string: string, kind: kind)

        let numbers = SnowflakeUtils.numbers(string: string)
        if numbers.count >= 4 {
            controlPoint2 = CGPoint(x: numbers[0], y: numbers[1])
            endPoint = CGPoint(x: numbers[2], y: numbers[3])
        }
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        if let previousCommand = previousCommand as? CurveToCommand {
            controlPoint1 = previousCommand.controlPoint2.reflect(around: path.currentPoint)
        } else if let previousCommand = previousCommand as? SmoothCurveToCommand {
            controlPoint1 = previousCommand.controlPoint2.reflect(around: path.currentPoint)
        } else {
            controlPoint1 = path.currentPoint
        }

        if kind == .relative {
            let current = path.currentPoint
            endPoint = current.add(p: endPoint)
            controlPoint2 = current.add(p: controlPoint2)
        }

        path.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
}

final class SmoothQuadraticBezierCurveToCommand: Command {
    var controlPoint: CGPoint = .zero
    var endPoint: CGPoint = .zero

    required init(string: String, kind: Kind) {
        super.init(string: string, kind: kind)

        let numbers = SnowflakeUtils.numbers(string: string)
        if numbers.count >= 2 {
            endPoint = CGPoint(x: numbers[0], y: numbers[1])
        }
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        if let previousCommand = previousCommand as? QuadraticBezierCurveCommand {
            controlPoint = previousCommand.controlPoint.reflect(around: path.currentPoint)
        } else if let previousCommand = previousCommand as? SmoothQuadraticBezierCurveToCommand {
            controlPoint = previousCommand.controlPoint.reflect(around: path.currentPoint)
        } else {
            controlPoint = path.currentPoint
        }

        if kind == .relative {
            endPoint = path.currentPoint.add(p: endPoint)
        }

        path.addQuadCurve(to: endPoint, controlPoint: controlPoint)
    }
}

final class VerticalLineToCommand: Command {
    var y: CGFloat = 0

    required init(string: String, kind: Kind) {
        super.init(string: string, kind: kind)

        let numbers = SnowflakeUtils.numbers(string: string)
        if let first = numbers.first {
            y = first
        }
    }

    override func act(path: UIBezierPath, previousCommand: Command?) {
        let end: CGPoint
        switch kind {
        case .absolute:
            end = CGPoint(x: path.currentPoint.x, y: y)
        case .relative:
            end = CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + y)
        }
        path.addLine(to: end)
    }
}

private struct SnowflakeUtils {
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
}

private extension CGPoint {
    func add(p: CGPoint) -> CGPoint {
        CGPoint(x: x + p.x, y: y + p.y)
    }

    func add(x: CGFloat) -> CGPoint {
        CGPoint(x: self.x + x, y: y)
    }

    func add(y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: self.y + y)
    }

    func subtract(p: CGPoint) -> CGPoint {
        CGPoint(x: x - p.x, y: y - p.y)
    }

    func reflect(point: CGPoint, old: CGPoint) -> CGPoint {
        CGPoint(x: 2 * x - point.x + old.x, y: 2 * y - point.y + old.y)
    }

    func reflect(around p: CGPoint) -> CGPoint {
        CGPoint(x: p.x * 2 - x, y: p.y * 2 - y)
    }
}
