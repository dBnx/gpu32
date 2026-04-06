
#include "lib/gpu32-isa.asm"
#include "lib/gpu32-lib.asm"

#bank memory_instruction

#const start = 0x0000
#const size  = 0x1000
#const fill  = 0xABCD

reset:
    ; TODO: Later read them from argument special registers
    ; SR.LD r31, a0 ; Start pointer
    ; SR.LD r29, a1 ; End   pointer
    ; SR.LD r30, a2 ; Fill data
    ; \-> SR.LD r30, r0, ?

    ADDI r31, r0, 0        ; Setup start pointer
    LI   r31, {start}      ; 

    ADDI r29, r0, 0        ; Setup end   pointer
    LI   r29, {size}       ; 
    ADD  r29, r29, r31     ;

    ADDI r30, r0, 0        ; Setup fill data
    LI   r30, {fill}       ; 

.clear_loop:
    ADDI r31, r31, 1           ; Increment 
    SEQ  r3,  r29, r31         ; Set if done 
    @p3 GLOBAL.ST r29, r31, 0  ; Not yet -> Store
    @p3 JP.ABS .clear_loop     ; Not yet -> Loop
.end:
    HALT   0
    JP.REL 0
    JP.REL 0
    JP.REL 0
    JP.REL 0