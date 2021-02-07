# Windfish architecture

The Windfish architecture is broken up into several Swift modules.

## Overview

Windfish is written in Swift and has primarily been tested on MacOS.
Linux and Windows support has yet to be verified ([see project](https://github.com/jverkoey/windfish/projects/5)).

At its core, Windfish provides an abstract representation of a CPU's instruction set via the `CPU` module.
Windfish currently only supports the [LR35902 instruction set](https://github.com/lmmendes/game-boy-opcodes) for the original Gameboy.
Other instruction sets could theoretically be supported in the future ([see project](https://github.com/jverkoey/windfish/projects/2)).

Concrete implementations of a CPU's instruction set are provided as separate modules.
For example, the `LR35902` module provides a concrete implementation of the LR35902 instruction set.

## Modules

- [CPU](CPU.md)
