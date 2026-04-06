
; #include "lib/gpu32-isa.asm"
#include "lib/gpu32-isa.asm"

#bank memory_instruction

reset:
test_arith:
    ZERO r1
    @p1 ZERO r1
    
    SWAP r1, r2

test_jp:
    JP.ABS 0
    JP.REL 0
    @true JP.ABS 0
    JP.ABS 0
    JP.ABS 0

test_li_byte:
    @p1 LLI   r1, 5
    @p1 LI.B0 r1, 5

    @p1 LLI   r1, 0x0A00
    @p1 LI.B1 r1, 0xA

    @p1 LUI   r1, 5
    @p1 LI.B2 r1, 5

    @p1 LUI   r1, 0x0A00
    @p1 LI.B3 r1, 0xA
test_li_word:
    @p1 LLI   r1, 0x1234
    @p1 LI.W0 r1, 0x1234

    @p1 LUI   r1, 0x4321
    @p1 LI.W1 r1, 0x4321
test_li_dword:
    @p1 ZERO   r1
    @p1 LLI    r1, 0x1234
    @p1 LUI    r1, 0x4321
    @p1 LI.DW0 r1, 0x43211234
    @p1 LI     r1, 0x43211234