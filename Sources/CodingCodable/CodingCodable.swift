// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum Error: Swift.Error, Sendable {
    case unarchiveFailed
}

@propertyWrapper
public struct CodingCodable<T: NSObject&NSCoding&Sendable>: Sendable {
    
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

@propertyWrapper
public struct CodingArrayCodable<T: NSObject&NSCoding&Sendable>: Sendable {
    public var wrappedValue: [T]

    public init(wrappedValue: [T]) {
        self.wrappedValue = wrappedValue
    }
}

extension CodingArrayCodable: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let datas = try container.decode([Data].self)
        self.wrappedValue = try datas.map { data in
            if let value = try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data) {
                return value
            }else {
                throw Error.unarchiveFailed
            }
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let datas = try wrappedValue.map { coding in
            try NSKeyedArchiver.archivedData(withRootObject: coding, requiringSecureCoding: true)
        }
        try container.encode(datas)
    }
}
