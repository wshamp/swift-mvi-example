//
//  OrderedDictionary.swift
//  cryptominingtracker
//
//  Created by Wyeth Shamp on 2/15/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import Foundation

public protocol OrderedDictionayComparable {
    associatedtype T: Comparable
    var comparable: T { get }
}

public struct OrderedDictionary<KeyType: Equatable & Hashable, ValueType: Equatable & CustomStringConvertible & OrderedDictionayComparable>: Hashable, CustomStringConvertible {
    typealias ArrayType = [KeyType]
    typealias DictionaryType = [KeyType: ValueType]
    
    internal var array = ArrayType()
    internal var dictionary = DictionaryType()
    
    public var count: Int {
        return self.array.count
    }
    
    public var description: String {
        if self.array.count > 0 {
            var newDescription = ""
            for key in self.array {
                guard let value = self.dictionary[key] else {
                    fatalError("No Value")
                }
                newDescription += value.description
            }
            return newDescription
        } else {
            return "OrderedDictionary-NoValues"
        }
    }
    
    public var hashValue: Int {
        return self.description.murHash
    }
    
    public mutating func insert(_ value: ValueType, forKey key: KeyType, atIndex index: Int) -> ValueType? {
        var adjustedIndex = index
        let existingValue = self.dictionary[key]
        if existingValue != nil {
            guard let existingIndex = self.array.index(of: key) else {
                fatalError("Missing Key")
            }
            if existingIndex < index {
                adjustedIndex -= 1
            }
            self.array.remove(at: existingIndex)
        }
        self.array.insert(key, at:adjustedIndex)
        self.dictionary[key] = value
        return existingValue
    }
    
    public mutating func append(_ value: ValueType, key: KeyType) {
        self.array.append(key)
        self.dictionary[key] = value
    }
    
    public mutating func remove(at index: Int) -> (key:KeyType, value:ValueType) {
        let key = self.array.remove(at: index)
        guard let value = self.dictionary.removeValue(forKey: key) , index < self.array.count else {
            fatalError("Index out-of-bounds")
        }
        return (key, value)
    }
    
    public mutating func sortAscending() {
        self.array.sort {
            guard let value1 = self.dictionary[$0], let value2 = self.dictionary[$1] else {
                fatalError("Index Out Of Range")
            }
            return value1.comparable < value2.comparable
        }
    }
    
    public mutating func sortDescending() {
        self.array.sort {
            guard let value1 = self.dictionary[$0], let value2 = self.dictionary[$1] else {
                fatalError("Index Out Of Range")
            }
            return value1.comparable > value2.comparable
        }
    }
    
    public func indexOfKey(_ key: KeyType) -> Int? {
        return self.array.index(of: key)
    }
    
    public subscript(key: KeyType) -> ValueType? {
        get {
            return self.dictionary[key]
        }
        set {
            if self.array.index(of: key) == nil {
                self.array.append(key)
            }
            self.dictionary[key] = newValue
        }
    }
    
    public subscript(index: Int) -> (key:KeyType, value:ValueType) {
        get {
            let key = self.array[index]
            guard let value = self.dictionary[key] , index < self.array.count else {
                fatalError("Index out-of-bounds")
            }
            return (key, value)
        }
    }
}

public func !=<KeyType, ValueType>(lhs:OrderedDictionary<KeyType, ValueType>, rhs:OrderedDictionary<KeyType, ValueType>) -> Bool {
    return lhs.hashValue != rhs.hashValue || lhs.array != rhs.array || lhs.dictionary != rhs.dictionary
}

public func ==<KeyType, ValueType>(lhs:OrderedDictionary<KeyType, ValueType>, rhs:OrderedDictionary<KeyType, ValueType>) -> Bool {
    return lhs.hashValue == rhs.hashValue && lhs.array == rhs.array && lhs.dictionary == rhs.dictionary
}

public extension String {
    var murHash: Int {
        get {
            let cString = self.cString(using: .utf8) ?? []
            let count = Int32(cString.count)
            let murHash = PMurHash32(0, cString, count)
            return Int(Int32(bitPattern: murHash))
        }
    }
}
