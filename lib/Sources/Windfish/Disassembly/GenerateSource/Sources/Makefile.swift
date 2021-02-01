import Foundation

extension Disassembler {
  func createMakefile() -> Source.FileDescription {
    return .makefile(content:"""
all: game.gb

game.o: game.asm bank_*.asm
\trgbasm -h -o game.o game.asm

game.gb: game.o
\trgblink -d -n game.sym -m game.map -o $@ $<
\trgbfix -v -p 255 $@

\tmd5 $@

clean:
\trm -f game.o game.gb game.sym game.map *.o
\tfind . \\( -iname '*.1bpp' -o -iname '*.2bpp' \\) -exec rm {} +

""")

  }
}
