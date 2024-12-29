//
//  OWQueue.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 29/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

protocol OWQueueProtocol {
    associatedtype Node
    // Main methods
    func popFirst() -> Node?
    func insert(_ node: Node)

    // Utility methods
    func pop(atIndex index: Int) -> Node?
    func insert(_ node: Node, atIndex index: Int)
    func index(of node: Node) -> Int?
    func isEmpty() -> Bool
}

class OWQueue<Node: Equatable & Codable>: OWQueueProtocol {
    private var queue: [Node] = []
    private let duplicationStrategy: OWQueueDuplicationStrategy

    init(duplicationStrategy: OWQueueDuplicationStrategy = .allowDuplicates) {
        self.duplicationStrategy = duplicationStrategy
    }

    func popFirst() -> Node? {
        return queue.isEmpty ? nil : queue.removeFirst()
    }

    func insert(_ node: Node) {
        switch duplicationStrategy {
        case .allowDuplicates:
            queue.append(node)
        case .ignoreDuplicates:
            if !queue.contains(where: { $0 == node }) {
                queue.append(node)
            }
        case .replaceDuplicates:
            queue.removeAll(where: { $0 == node })
            queue.append(node)
        }
    }

    func pop(atIndex index: Int) -> Node? {
        guard index < queue.count else { return nil }
        let node = queue[index]
        queue.remove(at: index)
        return node
    }

    func insert(_ node: Node, atIndex index: Int) {
        switch duplicationStrategy {
        case .allowDuplicates:
            insertOrAppend(node, atIndex: index)
        case .ignoreDuplicates:
            if !queue.contains(where: { $0 == node }) {
                insertOrAppend(node, atIndex: index)
            }
        case .replaceDuplicates:
            queue.removeAll(where: { $0 == node })
            insertOrAppend(node, atIndex: index)
        }
    }

    private func insertOrAppend(_ node: Node, atIndex index: Int) {
        if index < queue.count {
            queue.insert(node, at: index)
        } else {
            queue.append(node)
        }
    }

    func index(of node: Node) -> Int? {
        return queue.firstIndex(where: { $0 == node })
    }

    func isEmpty() -> Bool {
        return queue.isEmpty
    }
}
