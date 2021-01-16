#import "SameboyBridge.h"

void gb_get_backtrace_return(GB_gameboy_t *gb, int i, uint16_t *bank, uint16_t *addr) {
  *bank = gb->backtrace_returns[i].bank;
  *addr = gb->backtrace_returns[i].addr;
}
