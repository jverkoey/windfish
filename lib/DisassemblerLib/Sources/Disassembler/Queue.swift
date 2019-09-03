import Foundation

public struct Queue<T> {
  public init() {
  }

  public mutating func add(_ run: T) {
    queue.append(run)
  }

  public mutating func dequeue() -> T {
    return queue.removeFirst()
  }

  public var isEmpty: Bool {
    return queue.isEmpty
  }

  // TODO: Explore more optimal queue structures.
  private var queue: [T] = []
}
