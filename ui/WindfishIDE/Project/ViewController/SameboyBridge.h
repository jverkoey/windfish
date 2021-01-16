#import <Foundation/Foundation.h>

#import "Core/gb.h"

FOUNDATION_EXTERN
void gb_get_backtrace_return(GB_gameboy_t *gb, int i, uint16_t *bank, uint16_t *addr);
