
#include "lib/gpu32-isa.asm"

#bank memory_instruction

reset:
test_alu:
test_alu_add:
    ADD.4x8 r0, r0, r0
    ADD.2x16 r0, r0, r0
    ADD r0, r0, r0
    @true ADD r0, r0, r0

    ADD r1, r1, r1
    @p1 ADD r1, r1, r1

test_alu_sub:
    SUB r0, r0, r0
    @p1 SUB r1, r1, r1

test_alu_:

test_alui_add:
    ADDI r0, r0, 0
    @p1 ADDI r1, r1, 0x123

test_alui_:

test_lli:
    LLI r0, 0
    @p1 LLI r1, 0x1234
    
test_lui:
    LUI r0, 0
    @p1 LUI r1, 0x1234

test_io:
test_io_ld:
    GLOBAL.LD r0, r0 , 0
    GLOBAL.LD.B2 r0, r0 , 0
    @p1 GLOBAL.LD r1, r2 , 5
    @p1 GLOBAL.LD.B2 r1, r2 , 5

test_io_st:
    GLOBAL.ST r0, r0 , 0
    GLOBAL.ST.B2 r0, r0 , 0
    @p1 GLOBAL.ST r1, r2 , 5
    @p1 GLOBAL.ST.B2 r1, r2 , 5

test_io_other:
    LDS.LD r0, r0 , 0
    LDS.ST r0, r0 , 0
    SR.ST r0, r0 , 0
    SR.ST r0, r0 , -1

test_system:
test_system_jp:
    JP.REL  0
    @p1 JP.REL  0
    JP.REL  2
    JP.REL -1

test_system_:
    NOP 0
    @p1 NOP 0
    NOP 1
    NOP -1

    HALT 0
    @p1 HALT 0
    HALT 1
    HALT -1
