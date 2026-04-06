
#include "lib/gpu32-isa.asm"
#include "lib/gpu32-lib.asm"

#bank memory_instruction

reset:
    @true LI.DW0 r1, 0x1
    @p1 LI.DW0 r2, 0x1
    ; @p1 LI.DW0 r1, 0x1 ; FAILS
reset_clear:
    GLOBAL.clear.32 0x100, 0x100
reset_fill:
    GLOBAL.fill.32 0x100, 0x100, 0xAA