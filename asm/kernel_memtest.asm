; =============================================================================
; GPU32 Memory Test Kernel
; =============================================================================
; Tests both GLOBAL (RAM) and LDS memory regions per lane.
; Each of the 4 lanes tests its own memory region to ensure isolation.
;
; Memory layout per lane:
;   - GLOBAL: 0x0000 + lane_id*0x1000 (4KB per lane, 16KB total)
;   - LDS:   0x8000 + lane_id*0x0400 (1KB per lane, 4KB total)
;
; Test sequence:
;   1. Fill GLOBAL with 0xDEADBEEF
;   2. Verify GLOBAL contents
;   3. Fill LDS with 0xCAFEBABE
;   4. Verify LDS contents
;
; Results (in r27 on halt):
;   - 0: All tests passed
;   - non-zero: Address of first failure
; =============================================================================

#include "lib/gpu32-isa.asm"
#include "lib/gpu32-lib.asm"

#bank memory_instruction

#const GLOBAL_BASE = 0x0000
#const GLOBAL_SIZE = 0x1000
#const GLOBAL_FILL = 0xDEADBEEF
#const LDS_BASE    = 0x8000
#const LDS_SIZE    = 0x0400
#const LDS_FILL    = 0xCAFEBABE

reset:
    @true SR.LD r25, lane   ; r25 = lane ID (0-3)
    ZERO r27                ; r27 = 0 (no errors yet)

    SLLI  r24, r25, 12      ; r24 = lane_id * 0x1000
    ZERO r31
    LI   r31, GLOBAL_BASE   ; r31 = GLOBAL base
    ADD  r31, r31, r24      ; r31 = lane's GLOBAL start
    ZERO r30
    LI   r30, GLOBAL_SIZE   ; r30 = size
    ADD  r30, r30, r31      ; r30 = end address
    ZERO r29
    LI   r29, GLOBAL_FILL   ; r29 = fill pattern

    ; SR.LD r39, ARG5
    ; SR.LD r39, ARG5
    ; SR.LD r39, ARG5
    ; SR.LD r39, ARG5
    ; SR.LD r39, ARG5
    ; SR.LD r39, ARG5

    JP.REL .fill_loop_global

    .fill_loop_global:
        GLOBAL.ST r29, r31, 0   ; mem[r31] = r29
        ADDI r31, r31, 4        ; r31 += 4
        SEQ  r3, r31, r30       ; r3 = (r31 == r30)
        @r3 JP.REL .verify_global
        JP.REL .fill_loop_global

    .verify_global:
        SLLI  r31, r25, 12        ; r31 = lane_id * 0x1000
        ADD   r31, r31, r0        ; r31 = offset
        LI    r28, GLOBAL_BASE     ; r28 = GLOBAL_BASE (large constant = 0)
        ADD   r31, r31, r28       ; r31 = lane's GLOBAL start
        ADD   r28, r31, r0        ; r28 = copy for comparison

    .verify_global_check:
        GLOBAL.LD r28, r31, 0   ; r28 = mem[r31]
        SEQ  r3, r28, r29       ; r3 = (r28 == expected)
        @r3 JP.REL .global_next
        ADD  r27, r31, r0       ; r27 = error address
        JP.REL .fail

    .global_next:
        ADDI r31, r31, 4        ; r31 += 4
        SEQ  r3, r31, r30       ; r3 = (r31 == r30)
        @r3 JP.REL .test_lds
        JP.REL .verify_global_check

    .test_lds:
        SLLI r24, r25, 10        ; r24 = lane_id * 0x0400
        ZERO r31
        LI   r31, LDS_BASE       ; r31 = LDS base
        ADD r31, r31, r24       ; r31 = lane's LDS start
        ZERO r30
        LI   r30, LDS_SIZE      ; r30 = LDS size
        ADD r30, r30, r31       ; r30 = end address

    ZERO r29
    LI   r29, LDS_FILL     ; r29 = fill pattern

    JP.REL .fill_loop_lds

    .fill_loop_lds:
        LDS.ST r29, r31, 0     ; mem[r31] = r29
        ADDI r31, r31, 4        ; r31 += 4
        SEQ  r3, r31, r30       ; r3 = (r31 == r30)
        @r3 JP.REL .verify_lds
        JP.REL .fill_loop_lds

    .verify_lds:
        SLLI r31, r25, 10        ; r31 = lane_id * 0x0400
        ADD  r31, r31, r0        ; r31 = offset
        LI   r28, LDS_BASE       ; r28 = LDS_BASE (large constant)
        ADD  r31, r31, r28       ; r31 = lane's LDS start
        ADD  r28, r31, r0        ; r28 = copy for comparison

    .verify_lds_check:
        LDS.LD r28, r31, 0      ; r28 = mem[r31]
        SEQ  r3, r28, r29       ; r3 = (r28 == expected)
        @r3 JP.REL .all_pass
        ADD  r27, r31, r0       ; r27 = error address
        JP.REL .fail

.all_pass:
    ZERO r27                ; r27 = 0 (all pass)
    HALT 0                  ; halt with status in r27
.fail:
    HALT 1                  ; halt with status in r27
