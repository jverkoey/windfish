# Windfish architecture

The Windfish architecture is broken up into several Swift modules.

## Overview

Windfish is written in Swift and has primarily been tested on MacOS.
Linux and Windows support has yet to be verified ([see project](https://github.com/jverkoey/windfish/projects/5)).

At its core, Windfish provides an abstract representation of a CPU's instruction set via the `CPU` module.
The `LR35902` module then uses the `CPU` module to define the Gameboy CPU's instruction set.
The `LR35902` module forms the concrete foundation upon which the remaining modules are built.

The `Tracing` module is able to emulate the LR35902 instruction set and trace reads/writes via a sparse representation of a LR35902 CPU.
Tracing is primarily used for type inference during disassembly.

The `RGBDS` module provides an intermediary tokenized representation of an [RGBDS](https://github.com/gbdev/rgbds)-compatible assembly statement.
This representation standardizes disassembly output and enables macro inference during disassembly.

The `Windfish` module provides the disassembler.
The disassembler is multi-threaded and highly configurable, and it can be used as a command line utility or in an interactive development environment.

## Modules

- [CPU](CPU/index.md)
