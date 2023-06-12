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

protocol OWUpdaterProtocol {
    var update: PublishSubject<Void> { get }
}

extension OWUpdaterProtocol {
    var update: PublishSubject<Void> {
        return PublishSubject<Void>()
    }
}

class OWObservableArray<Element: OWUpdaterProtocol>: ExpressibleByArrayLiteral {
    typealias EventType = OWArrayChangeEvent

    fileprivate let eventSubject = PublishSubject<EventType>()
    fileprivate let elementsSubject: BehaviorSubject<[Element]>

    fileprivate var disposedBag = DisposeBag()

    fileprivate var elements: [Element]

    required init() {
        self.elements = []
        self.elementsSubject = BehaviorSubject<[Element]>(value: [])
    }

    init(count: Int, repeatedValue: Element) {
        self.elements = Array(repeating: repeatedValue, count: count)
        self.elementsSubject = BehaviorSubject<[Element]>(value: elements)
        self.setupObserversForElementsUpdater()
    }

    required init<S: Sequence>(_ s: S) where S.Iterator.Element == Element {
        self.elements = Array(s)
        self.elementsSubject = BehaviorSubject<[Element]>(value: elements)
        self.setupObserversForElementsUpdater()
    }

    required init(arrayLiteral elements: Element...) {
        self.elements = elements
        self.elementsSubject = BehaviorSubject<[Element]>(value: elements)
        self.setupObserversForElementsUpdater()
    }
}

extension OWObservableArray {
    func rx_elements() -> Observable<[Element]> {
        return elementsSubject
    }

    func rx_events() -> Observable<EventType> {
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
    func reserveCapacity(_ minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }

    func append(_ newElement: Element) {
        elements.append(newElement)
        setupObserversForElementsUpdater()
        arrayDidChange(OWArrayChangeEvent(inserted: [elements.count - 1]))
    }

    func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element {
        let end = elements.count
        elements.append(contentsOf: newElements)
        setupObserversForElementsUpdater()
        guard end != elements.count else {
            return
        }
        arrayDidChange(OWArrayChangeEvent(inserted: Array(end..<elements.count)))
    }

    func appendContentsOf<C: Collection>(_ newElements: C) where C.Iterator.Element == Element {
        guard !newElements.isEmpty else {
            return
        }
        let end = elements.count
        elements.append(contentsOf: newElements)
        setupObserversForElementsUpdater()
        arrayDidChange(OWArrayChangeEvent(inserted: Array(end..<elements.count)))
    }

    @discardableResult func removeLast() -> Element {
        let e = elements.removeLast()
        setupObserversForElementsUpdater()
        arrayDidChange(OWArrayChangeEvent(deleted: [elements.count]))
        return e
    }

    func insert(_ newElement: Element, at i: Int) {
        elements.insert(newElement, at: i)
        setupObserversForElementsUpdater()
        arrayDidChange(OWArrayChangeEvent(inserted: [i]))
    }

    @discardableResult func remove(at index: Int) -> Element {
        let e = elements.remove(at: index)
        setupObserversForElementsUpdater()
        arrayDidChange(OWArrayChangeEvent(deleted: [index]))
        return e
    }

    @discardableResult func remove(at indices: [Int]) -> [Element] {
        let sortedIndices = indices.sorted { $0 > $1 }
        var elementsToReturn = [Element]( )

        for index in sortedIndices {
            let e = elements.remove(at: index)
            elementsToReturn.append(e)
        }

        arrayDidChange(OWArrayChangeEvent(deleted: indices))
        return elementsToReturn
    }

    func update(elementsWithIndices: [(Element, Int)]) {
        let regularSorted = elementsWithIndices.sorted { $0.1 < $1.1 }
        let reverseSorted = elementsWithIndices.sorted { $0.1 > $1.1 }

        for elementAndIndex in reverseSorted {
            elements.remove(at: elementAndIndex.1)
        }

        for elementAndIndex in regularSorted {
            elements.insert(elementAndIndex.0, at: elementAndIndex.1)
        }

        let indices = elementsWithIndices.map { $0.1 }
        arrayDidChange(OWArrayChangeEvent(updated: indices))
    }

    func removeAll(_ keepCapacity: Bool = false) {
        guard !elements.isEmpty else {
            return
        }
        let originalElements = elements
        elements.removeAll(keepingCapacity: keepCapacity)
        setupObserversForElementsUpdater()
        arrayDidChange(OWArrayChangeEvent(deleted: Array(0..<originalElements.count)))
    }

    func insertContentsOf(_ newElements: [Element], atIndex i: Int) {
        guard !newElements.isEmpty else {
            return
        }
        elements.insert(contentsOf: newElements, at: i)
        setupObserversForElementsUpdater()
        arrayDidChange(OWArrayChangeEvent(inserted: Array(i..<i + newElements.count)))
    }

    func popLast() -> Element? {
        let e = elements.popLast()
        setupObserversForElementsUpdater()
        if e != nil {
            arrayDidChange(OWArrayChangeEvent(deleted: [elements.count]))
        }
        return e
    }

    func replaceAll(with newElements: [Element]) {
        let originalElements = elements
        elements.removeAll(keepingCapacity: true)
        elements.insert(contentsOf: newElements, at: 0)
        setupObserversForElementsUpdater()
        if (originalElements.count == 0) {
            arrayDidChange(OWArrayChangeEvent(inserted: Array(0..<newElements.count)))
        } else if (originalElements.count < newElements.count) {
            arrayDidChange(OWArrayChangeEvent(updated: Array(0..<originalElements.count)))
            arrayDidChange(OWArrayChangeEvent(inserted: Array(originalElements.count..<newElements.count)))
        } else {
            arrayDidChange(OWArrayChangeEvent(updated: Array(0..<newElements.count)))
            if (newElements.count != originalElements.count) {
                arrayDidChange(OWArrayChangeEvent(deleted: Array(newElements.count..<originalElements.count)))
            }
        }
    }
}

extension OWObservableArray: RangeReplaceableCollection {
    func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newCollection: C) where C.Iterator.Element == Element {
        let oldCount = elements.count
        elements.replaceSubrange(subRange, with: newCollection)
        setupObserversForElementsUpdater()
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
            setupObserversForElementsUpdater()
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
            setupObserversForElementsUpdater()
            let first = bounds.lowerBound
            arrayDidChange(OWArrayChangeEvent(inserted: Array(first..<first + newValue.count),
                                            deleted: Array(bounds.lowerBound..<bounds.upperBound)))
        }
    }
}

fileprivate extension OWObservableArray {
    func setupObserversForElementsUpdater() {
        self.disposedBag = DisposeBag()

        let elementsUpdaterObservables = elements.enumerated().map { (idx, element) -> Observable<Int> in
            return element.update
                .asObservable()
                .map { idx }
        }

        Observable.merge(elementsUpdaterObservables)
            .subscribe { [weak self] idx in
                guard let self = self else { return }
                self.arrayDidChange(OWArrayChangeEvent(updated: [idx]))
            }
            .disposed(by: disposedBag)
    }
}
