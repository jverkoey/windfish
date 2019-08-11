import Foundation

extension LR35902.Disassembly {
  class RunQueue {
    func add(_ run: Run) {
      runQueue.append(run)
    }

    func dequeue() -> Run {
      let run = runQueue.removeFirst()
      history.append(run)
      return run
    }

    var isEmpty: Bool {
      return runQueue.isEmpty
    }

    var history: [Run] = []

    private var runQueue: [Run] = []
  }
}
