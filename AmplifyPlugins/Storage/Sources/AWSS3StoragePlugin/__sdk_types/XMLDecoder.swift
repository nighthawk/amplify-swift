//
//  File.swift
//  
//
//  Created by Saultz, Ian on 11/6/23.
//

import Foundation

class XMLDecoder<Model>: NSObject, XMLParserDelegate {
    func decode(data: Data) throws -> Model {
        let parser = XMLParser(data: data)
        parser.delegate = self
        let success = parser.parse()

        if success {
            return model
        } else {
            throw parser.parserError!
        }
    }

    enum PropertyState {
        case pending, processing, complete
    }

    var decodeMap: [String: (PropertyState, WritableKeyPath<Model, String?>)]
    var model: Model

    init(
        decodeMap: [String: (PropertyState, WritableKeyPath<Model, String?>)],
        model: Model
    ) {
        self.decodeMap = decodeMap
        self.model = model
    }

    var keyPathInProccess: WritableKeyPath<Model, String?>? {
        decodeMap.values.first(where: { $0.0 == .processing })?.1
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if let (state, keyPath) = decodeMap[elementName], state == .pending {
            decodeMap[elementName] = (.processing, keyPath)
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let (state, keyPath) = decodeMap[elementName], state == .processing {
            decodeMap[elementName] = (.complete, keyPath)
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            guard let keyPathInProccess else {
                print(">>> Error: no processing keypath found in decodeMap: \(decodeMap)")
                return
            }
            model[keyPath: keyPathInProccess] = string
        }
    }
}
