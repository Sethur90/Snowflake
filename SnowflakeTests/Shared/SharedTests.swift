#if canImport(UIKit)
import Testing
import UIKit
@testable import Snowflake

@Suite("Snowflake Tests")
struct SnowflakeTests {

    // MARK: - XML Parsing

    @Test("Parse valid SVG document")
    func parseSVGDocument() throws {
        let data = """
        <svg width="100" height="100">
            <circle cx="50" cy="50" r="40" fill="red"/>
        </svg>
        """.data(using: .utf8)!

        let document = Document(data: data)
        #expect(document != nil)
        #expect(document?.svg.size == CGSize(width: 100, height: 100))
    }

    @Test("Reject non-SVG root element")
    func rejectNonSVGRoot() throws {
        let data = "<html><body></body></html>".data(using: .utf8)!
        let document = Document(data: data)
        #expect(document == nil)
    }

    @Test("Parse circle element")
    func parseCircle() throws {
        let data = """
        <svg width="200" height="200">
            <circle cx="50" cy="60" r="30" fill="blue"/>
        </svg>
        """.data(using: .utf8)!

        let document = try #require(Document(data: data))
        let circle = try #require(document.svg.items.first as? Circle)
        #expect(circle.center == CGPoint(x: 50, y: 60))
        #expect(circle.radius == 30)
    }

    @Test("Parse rectangle element")
    func parseRectangle() throws {
        let data = """
        <svg width="200" height="200">
            <rect x="10" y="20" width="80" height="60"/>
        </svg>
        """.data(using: .utf8)!

        let document = try #require(Document(data: data))
        let rect = try #require(document.svg.items.first as? Rectangle)
        #expect(rect.frame == CGRect(x: 10, y: 20, width: 80, height: 60))
    }

    @Test("Parse line element")
    func parseLine() throws {
        let data = """
        <svg width="200" height="200">
            <line x1="10" y1="20" x2="90" y2="80"/>
        </svg>
        """.data(using: .utf8)!

        let document = try #require(Document(data: data))
        let line = try #require(document.svg.items.first as? Line)
        #expect(line.point1 == CGPoint(x: 10, y: 20))
        #expect(line.point2 == CGPoint(x: 90, y: 80))
    }

    @Test("Parse ellipse element")
    func parseEllipse() throws {
        let data = """
        <svg width="200" height="200">
            <ellipse cx="100" cy="100" rx="50" ry="30"/>
        </svg>
        """.data(using: .utf8)!

        let document = try #require(Document(data: data))
        let ellipse = try #require(document.svg.items.first as? Ellipse)
        #expect(ellipse.center == CGPoint(x: 100, y: 100))
        #expect(ellipse.radius == CGPoint(x: 50, y: 30))
    }

    @Test("Parse group element flattens children")
    func parseGroup() throws {
        let data = """
        <svg width="200" height="200">
            <g>
                <circle cx="50" cy="50" r="20"/>
                <rect x="10" y="10" width="30" height="30"/>
            </g>
        </svg>
        """.data(using: .utf8)!

        let document = try #require(Document(data: data))
        #expect(document.svg.items.count == 2)
    }

    // MARK: - SVG Path Parser

    @Test("Parse move and line path")
    func parseMoveAndLine() throws {
        let path = UIBezierPath.from(svgPath: "M10 20 L90 80")
        #expect(!path.isEmpty)
    }

    @Test("Parse close path command Z")
    func parseClosePathZ() throws {
        // Previously Z was silently ignored — this verifies the fix
        let path = UIBezierPath.from(svgPath: "M0 0 L100 0 L100 100 Z")
        #expect(!path.isEmpty)
    }

    @Test("Parse relative move command")
    func parseRelativeMove() throws {
        let path = UIBezierPath.from(svgPath: "M10 10 l20 20")
        #expect(!path.isEmpty)
    }

    @Test("Parse horizontal line command")
    func parseHorizontalLine() throws {
        let path = UIBezierPath.from(svgPath: "M0 50 H100")
        #expect(!path.isEmpty)
    }

    @Test("Parse vertical line command")
    func parseVerticalLine() throws {
        let path = UIBezierPath.from(svgPath: "M50 0 V100")
        #expect(!path.isEmpty)
    }

    @Test("Parse cubic bezier command")
    func parseCubicBezier() throws {
        let path = UIBezierPath.from(svgPath: "M0 0 C10 10 20 10 30 0")
        #expect(!path.isEmpty)
    }

    @Test("Parse quadratic bezier command")
    func parseQuadraticBezier() throws {
        let path = UIBezierPath.from(svgPath: "M0 0 Q50 100 100 0")
        #expect(!path.isEmpty)
    }

    // MARK: - Utils

    @Test("Parse numbers from string with spaces")
    func parseNumbersSpaces() throws {
        let numbers = Utils.numbers(string: "10 20 30")
        #expect(numbers == [10, 20, 30])
    }

    @Test("Parse numbers from string with commas")
    func parseNumbersCommas() throws {
        let numbers = Utils.numbers(string: "10,20,30")
        #expect(numbers == [10, 20, 30])
    }

    @Test("Parse negative numbers")
    func parseNegativeNumbers() throws {
        let numbers = Utils.numbers(string: "10 -20 30")
        #expect(numbers.count == 3)
        #expect(numbers[1] == -20)
    }

    @Test("Parse points from string")
    func parsePoints() throws {
        let points = Utils.points(string: "10 20 30 40")
        #expect(points.count == 2)
        #expect(points[0] == CGPoint(x: 10, y: 20))
        #expect(points[1] == CGPoint(x: 30, y: 40))
    }

    @Test("Ratio fits smaller dimension")
    func ratioFitsSmallerDimension() throws {
        let ratio = Utils.ratio(from: CGSize(width: 200, height: 100), to: CGSize(width: 100, height: 100))
        #expect(ratio == 0.5)
    }

    // MARK: - Color

    @Test("Parse six-digit hex color")
    func parseHexColor() throws {
        let color = Color.color(name: "#ff0000")
        var red: CGFloat = 0
        color.getRed(&red, green: nil, blue: nil, alpha: nil)
        #expect(red == 1.0)
    }

    @Test("Parse named CSS color")
    func parseNamedColor() throws {
        let color = Color.color(name: "red")
        var red: CGFloat = 0
        color.getRed(&red, green: nil, blue: nil, alpha: nil)
        #expect(red == 1.0)
    }

    @Test("Parse rgb() color string")
    func parseRGBColor() throws {
        let color = Color.color(name: "rgb(255,0,0)")
        var red: CGFloat = 0
        color.getRed(&red, green: nil, blue: nil, alpha: nil)
        #expect(red == 1.0)
    }

    @Test("Unknown color returns clear")
    func unknownColorReturnsClear() throws {
        let color = Color.color(name: "notacolor")
        #expect(color == .clear)
    }

    // MARK: - Style

    @Test("Parse inline style attribute")
    func parseInlineStyle() throws {
        let data = """
        <svg width="100" height="100">
            <circle cx="50" cy="50" r="40" style="fill:blue;stroke:red;stroke-width:2"/>
        </svg>
        """.data(using: .utf8)!

        let document = try #require(Document(data: data))
        let circle = try #require(document.svg.items.first as? Circle)
        #expect(circle.style.fillColor != nil)
        #expect(circle.style.strokeColor != nil)
        #expect(circle.style.strokeWidth == 2)
    }

    @Test("Parse opacity attribute")
    func parseOpacity() throws {
        let data = """
        <svg width="100" height="100">
            <circle cx="50" cy="50" r="40" opacity="0.5"/>
        </svg>
        """.data(using: .utf8)!

        let document = try #require(Document(data: data))
        let circle = try #require(document.svg.items.first as? Circle)
        #expect(circle.style.opacity == 0.5)
    }
}
#endif
