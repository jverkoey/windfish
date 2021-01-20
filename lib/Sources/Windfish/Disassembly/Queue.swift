import Foundation

public final class Queue<T> {
  public func add(_ run: T) {
    queue.append(run)
  }

  public func dequeue() -> T {
    return queue.removeFirst()
  }

  public var isEmpty: Bool {
    return queue.isEmpty
  }

  // TODO: Explore more optimal queue structures.
  private var queue: [T] = []
}
