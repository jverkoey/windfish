# Windfish architecture

The Windfish architecture is broken up into several Swift modules.
Before diving into a module, let's establish the high level architectural details.

## Overview

Windfish is written in Swift.
Thus far it has primarily been tested on MacOS.
Linux and Windows support has yet to be verified (https://github.com/jverkoey/windfish/issues/59).

At its core, Windfish provides an abstract representation of a CPU's instruction set via the `CPU` module.
Windfish currently only supports the [LR35902 instruction set](https://github.com/lmmendes/game-boy-opcodes) for the original Gameboy.
Other instruction sets could theoretically be supported in the future (https://github.com/jverkoey/windfish/projects/2).

## Modules

- [CPU](CPU.md)
