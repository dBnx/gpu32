#once
#include "gpu32-isa.asm"

; TODO: Move video helper funcitons here after stabilizing CALL / RET
;       Also think of some RGB565 helper functions as long as SIMD is not available.
;       Maybe read a global define: that either implements the instructions in -base
;       or implements them here as macros.

#ruledef {
    GLOBAL.fill.32 {start: u32}, {size: u32}, {value: u32} => asm {
            LI   r31, {start}      ; Setup start pointer
            ADDI r29, r31, {size}  ; Setup end   pointer
            ADDI r30, r0, 0        ; Setup fill data
            LI   r30, {value}      ;  
        clear_loop:
            ADDI r31, r31, 1 ; Increment 
            SEQ  r3,  r29, r31 
            @p3 GLOBAL.ST r29, r31, 0
            @p3 JP.ABS clear_loop
        end:

    }
    GLOBAL.clear.32 {start: u32}, {size: u32} => asm { GLOBAL.fill.32 {start}, {size}, 0 }
}