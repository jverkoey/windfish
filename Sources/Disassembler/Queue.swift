import Foundation

public class Queue<T> {
  public init() {
  }

  public func add(_ run: T) {
    runQueue.append(run)
  }

  public func dequeue() -> T {
    return runQueue.removeFirst()
  }

  public var isEmpty: Bool {
    return runQueue.isEmpty
  }

  // TODO: Explore more optimal queue structures.
  private var runQueue: [T] = []
}
