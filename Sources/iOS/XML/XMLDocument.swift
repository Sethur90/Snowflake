import Foundation

final class SVGXMLDocument: @unchecked Sendable {
    let rootElement: Element

    enum ParseError: Error {
        case noRootElement
        case parserError(Error)
    }

    init(data: Data) throws {
        let handler = XMLParserHandler()
        let parser = XMLParser(data: data)
        parser.delegate = handler
        parser.parse()

        if let error = handler.parseError {
            throw ParseError.parserError(error)
        }

        guard let root = handler.rootElement else {
            throw ParseError.noRootElement
        }

        self.rootElement = root
    }
}

private final class XMLParserHandler: NSObject, XMLParserDelegate, @unchecked Sendable {
    var rootElement: Element?
    var parseError: Error?
    private var stack: [(name: String, attributes: [String: String], children: [Element])] = []

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        stack.append((name: elementName, attributes: attributeDict, children: []))
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard let top = stack.popLast() else { return }
        let element = Element(name: top.name, attributes: top.attributes, children: top.children)

        if stack.isEmpty {
            rootElement = element
        } else {
            stack[stack.count - 1].children.append(element)
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
}
