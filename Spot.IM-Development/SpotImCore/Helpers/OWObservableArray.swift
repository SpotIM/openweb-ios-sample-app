//
//  ObservableArray.swift
//  SpotImCore
//
//  Created by Alon Haiut on 10/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

struct OWArrayChangeEvent {
    let insertedIndices: [Int]
    let deletedIndices: [Int]
    let updatedIndices: [Int]

    fileprivate init(inserted: [Int] = [], deleted: [Int] = [], updated: [Int] = []) {
        assert(inserted.count + deleted.count + updated.count > 0)
        insertedIndices = inserted
        deletedIndices = deleted
        updatedIndices = updated
    }
}

struct OWObservableArray<Element>: ExpressibleByArrayLiteral {
    typealias EventType = OWArrayChangeEvent

    fileprivate let eventSubject = PublishSubject<EventType>()
    fileprivate let elementsSubject: BehaviorSubject<[Element]>
    fileprivate var elements: [Element]

    init() {
        elements = []
        elementsSubject = BehaviorSubject<[Element]>(value: [])
    }

    init(count: Int, repeatedValue: Element) {
        elements = Array(repeating: repeatedValue, count: count)
        elementsSubject = BehaviorSubject<[Element]>(value: elements)
    }

    init<S : Sequence>(_ s: S) where S.Iterator.Element == Element {
        elements = Array(s)
        elementsSubject = BehaviorSubject<[Element]>(value: elements)
    }

    init(arrayLiteral elements: Element...) {
        self.elements = elements
        elementsSubject = BehaviorSubject<[Element]>(value: elements)
    }
}

extension OWObservableArray {
    mutating func rx_elements() -> Observable<[Element]> {
        return elementsSubject
    }

    mutating func rx_events() -> Observable<EventType> {
        return eventSubject
    }

    fileprivate func arrayDidChange(_ event: EventType) {
        elementsSubject.onNext(elements)
        eventSubject.onNext(event)
    }
}

extension OWObservableArray: Collection {
    var capacity: Int {
        return elements.capacity
    }

    var startIndex: Int {
        return elements.startIndex
    }

    var endIndex: Int {
        return elements.endIndex
    }

    func index(after i: Int) -> Int {
        return elements.index(after: i)
    }
}

extension OWObservableArray: MutableCollection {
    mutating func reserveCapacity(_ minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }

    mutating func append(_ newElement: Element) {
        elements.append(newElement)
        arrayDidChange(OWArrayChangeEvent(inserted: [elements.count - 1]))
    }

    mutating func append<S : Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element {
        let end = elements.count
        elements.append(contentsOf: newElements)
        guard end != elements.count else {
            return
        }
        arrayDidChange(OWArrayChangeEvent(inserted: Array(end..<elements.count)))
    }

    mutating func appendContentsOf<C : Collection>(_ newElements: C) where C.Iterator.Element == Element {
        guard !newElements.isEmpty else {
            return
        }
        let end = elements.count
        elements.append(contentsOf: newElements)
        arrayDidChange(OWArrayChangeEvent(inserted: Array(end..<elements.count)))
    }

    @discardableResult mutating func removeLast() -> Element {
        let e = elements.removeLast()
        arrayDidChange(OWArrayChangeEvent(deleted: [elements.count]))
        return e
    }

    mutating func insert(_ newElement: Element, at i: Int) {
        elements.insert(newElement, at: i)
        arrayDidChange(OWArrayChangeEvent(inserted: [i]))
    }

    @discardableResult mutating func remove(at index: Int) -> Element {
        let e = elements.remove(at: index)
        arrayDidChange(OWArrayChangeEvent(deleted: [index]))
        return e
    }

    mutating func removeAll(_ keepCapacity: Bool = false) {
        guard !elements.isEmpty else {
            return
        }
        let originalElements = elements
        elements.removeAll(keepingCapacity: keepCapacity)
        arrayDidChange(OWArrayChangeEvent(deleted: Array(0..<originalElements.count)))
    }

    mutating func insertContentsOf(_ newElements: [Element], atIndex i: Int) {
        guard !newElements.isEmpty else {
            return
        }
        elements.insert(contentsOf: newElements, at: i)
        arrayDidChange(OWArrayChangeEvent(inserted: Array(i..<i + newElements.count)))
    }

    mutating func popLast() -> Element? {
        let e = elements.popLast()
        if e != nil {
            arrayDidChange(OWArrayChangeEvent(deleted: [elements.count]))
        }
        return e
    }
}

extension OWObservableArray: RangeReplaceableCollection {
    mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newCollection: C) where C.Iterator.Element == Element {
        let oldCount = elements.count
        elements.replaceSubrange(subRange, with: newCollection)
        let first = subRange.lowerBound
        let newCount = elements.count
        let end = first + (newCount - oldCount) + subRange.count
        arrayDidChange(OWArrayChangeEvent(inserted: Array(first..<end),
                                        deleted: Array(subRange.lowerBound..<subRange.upperBound)))
    }
}

extension OWObservableArray: CustomDebugStringConvertible {
    var description: String {
        return elements.description
    }
}

extension OWObservableArray: CustomStringConvertible {
    var debugDescription: String {
        return elements.debugDescription
    }
}

extension OWObservableArray: Sequence {

    subscript(index: Int) -> Element {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
            if index == elements.count {
                arrayDidChange(OWArrayChangeEvent(inserted: [index]))
            } else {
                arrayDidChange(OWArrayChangeEvent(updated: [index]))
            }
        }
    }

    subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        get {
            return elements[bounds]
        }
        set {
            elements[bounds] = newValue
            let first = bounds.lowerBound
            arrayDidChange(OWArrayChangeEvent(inserted: Array(first..<first + newValue.count),
                                            deleted: Array(bounds.lowerBound..<bounds.upperBound)))
        }
    }
}

