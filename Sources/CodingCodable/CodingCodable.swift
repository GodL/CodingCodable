// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@propertyWrapper
public struct CodingCodable<T: NSObject&NSCoding> {
    
    public enum Error: Swift.Error {
        case unarchiveFailed
    }
    
    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

extension CodingCodable : Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        if let value = try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data) {
            self.wrappedValue = value
        }else {
            throw Error.unarchiveFailed
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try NSKeyedArchiver.archivedData(withRootObject: wrappedValue, requiringSecureCoding: true)
        try container.encode(data)
    }
}
