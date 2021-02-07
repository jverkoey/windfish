import Foundation

/**
 A representation of the location from which a trace event occurred.

 This is typically a memory address of some form.
 */
public protocol SourceLocation: Hashable {}

/** A representation of a register whose read/write access can be traced. */
public protocol TraceableRegister: Hashable {}

/** Potential trace events for a given register. */
public enum RegisterTrace<SpecType: InstructionSpec, SourceLocationType: SourceLocation>: Equatable {
  /** The register's value was stored to an address in memory. */
  case storeToAddress(SpecType.AddressType)

  /** The register's value was loaded from an address in memory. */
  case loadFromAddress(SpecType.AddressType)

  /** The register's value was loaded from an immediate at some source location. */
  case loadImmediateFromSourceLocation(SourceLocationType)

  /** The register's value was modified using an immediate at some source location. */
  case mutationWithImmediateAtSourceLocation(SourceLocationType)

  /** The register's value was modified at some source location. */
  case mutationFromAddress(SourceLocationType)
}

/** A representation of traceable read/write access for the memory and registers of a system. */
public protocol TraceableMemory: class {
  associatedtype SpecType: InstructionSpec
  associatedtype SourceLocationType: SourceLocation
  associatedtype RegisterType: TraceableRegister

  // MARK: Accessing memory

  /** Read from the given address and return the resulting byte, if it's known. */
  func read(from address: SpecType.AddressType) -> UInt8?

  /** Write a byte to the given address. Writing nil should clear any known value at the given address. */
  func write(_ byte: UInt8?, to address: SpecType.AddressType)

  /** Returns a source code location for the given address based on the current memory configuration. */
  func sourceLocation(from address: SpecType.AddressType) -> SourceLocationType

  // MARK: Tracing register access

  /** Trace information for a given register. */
  var registerTraces: [RegisterType: [RegisterTrace<SpecType, SourceLocationType>]] { get set }
}
