import Foundation

public struct Element: Sendable {
    public let name: String?
    public let attributes: [String: String]
    private let childElements: [Element]

    public init(name: String?, attributes: [String: String], children: [Element] = []) {
        self.name = name
        self.attributes = attributes
        self.childElements = children
    }

    public func children() -> [Element] {
        childElements
    }
}
