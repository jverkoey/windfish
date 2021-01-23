---
title: Welcome
description: Welcome to Windfish
order: -.INF
---

Windfish is a Gameboy ROM disassembler.
The Windfish IDE provides a user interface for editing Windfish projects and it is tightly integrated with the [Sameboy emulator](http://github.com/liJI32/SameBoy/).
Windfish is primarily intended for performing archaeological explorations of existing retro games.

## Overview

![Windfish UI](overview-disassembler.png)

The Windfish app provides a project-based workflow for disassembling ROMs.

The leading pane is called the Navigator.
At the top, the Navigator shows all of the files that have been generated from the project's ROM.
At the bottom, the Navigator shows the call stack of the current debugging session.

The center pane consists of the Editor and Console.
The Editor provides a read-only view of the generated assembly for the ROM.
The Console provides a read-evaluate-print-loop (REPL) interface to the Sameboy emulator.
See [Sameboy's Textual Debugger Documentation](https://sameboy.github.io/debugger/) for full details on working with the debugger.

The trailing pane is called the Inspector.
The Inspector pane has nested tabs that allow you to edit and inspect the Windfish project's configuration.
The edit tab includes:

- The Region editor.
- The Data Type editor.
- The Global editor.
- The Macro editor.
- The Script editor.

The inspect tab includes:

- The Region inspector.
