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

## Disassembling your first ROM

Windfish is a project-based disassembler that relies on your input to guide it toward an ideal disassembly.

To create a new project, open Windfish and click File > New Project.
This will create an empty project.
You can now load a ROM for disassembly into the project by clicking File > Load ROM....

Once the ROM is loaded, Windfish will immediately begin disassembling it.
Once complete, the UI will show you the list of ROM banks in the Navigator.

Clicking any of the files in the Navigator will open a read-only view of that file in the Editor.

By default, Windfish will populate the project with several regions that are standard for Gameboy ROMs.

- `$00:$0040: region`: VBlankInterrupt, length: 8 bytes
- `$00:$0048: region`: LCDCInterrupt, length: 8 bytes
- `$00:$0050: region`: TimerOverflowInterrupt, length: 8 bytes
- `$00:$0058: region`: SerialTransferCompleteInterrupt, length: 8 bytes
- `$00:$0060: region`: JoypadTransitionInterrupt, length: 8 bytes
- `$00:$0100: region`: Boot, length: 4 bytes
- `$00:$0104: image1bpp`: HeaderLogo, length: 48 bytes
- `$00:$0134: string`: HeaderTitle, length: 15 bytes
- `$00:$0144: label`: HeaderNewLicenseeCode, length: 0 bytes
- `$00:$014B: label`: HeaderOldLicenseeCode, length: 0 bytes
- `$00:$014C: label`: HeaderMaskROMVersion, length: 0 bytes
- `$00:$014D: label`: HeaderComplementCheck, length: 0 bytes
- `$00:$014E: label`: HeaderGlobalChecksum, length: 0 bytes

These defaults provide a solid starting point for inspecting and understanding the ROM's behavior.

The standard Gameboy register addresses and some common data types are also registered by default.
