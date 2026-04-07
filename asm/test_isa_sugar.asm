
#include "lib/gpu32-isa.asm"

#bank memory_instruction

reset:

li:
li_byte:
    LI.B0 r1, 0x12
    LI.B1 r1, 0x12
    LI.B2 r1, 0x12
    LI.B3 r1, 0x12
li_word_dword:
    LI.W0 r1, 0x5678
    LI.W1 r1, 0x1234
    ; 
    LI.DW0 r1, 0x1234_5678