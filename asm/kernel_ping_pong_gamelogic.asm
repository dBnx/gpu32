
#include "lib/gpu32-isa.asm"
#include "lib/gpu32-lib.asm"

; r 8
#const LDS_ADDR_BALL_POS_X  0x0000
; r 9
#const LDS_ADDR_BALL_POS_Y  0x0004
; r10
#const LDS_ADDR_BALL_SIZE   0x0008
; r11
#const LDS_ADDR_BALL_MASK   0x0010
; 0 is left, 1 is right
#const LDS_ADDR_BALL_DIR    0x0014

; r12
#const LDS_ADDR_PADDLE_POS  0x0020
; r13
#const LDS_ADDR_PADDLE_SIZE 0x0024
; r14
#const LDS_ADDR_PADDLE_MASK 0x0024

; Right after the FB, so the next line is the score
#const GLOBAL_ADDR_SCORE    32

entry:
    ; Preparation:
    ZERO    r1             ; p1 true if lane 0
    SR.LD   r1,  wg.x      ; 
    SEZ     r1,  r1
    @!p1    HALT 0

    LDS.LD  r11, LDS_ADDR_PADDLE_MASK
    NOT     r2,  r11                    ; True if uninit
    AND     r2,  r2,  r1                ; True if uninit and lane0
    ; TODO: in the future jumpt to .initialization
    ; @p2 JP.ABS .initialization

    ; Initialize if p2, otherwise load values from LDS
    .initialization:
        ; TODO: ..
        @p2 ADDI   r8, r0, 1
        @p2 LDS.ST r8, LDS_ADDR_BALL_POS_X

        @p2 ADDI   r8, r0, 0
        @p2 LDS.ST r8, LDS_ADDR_BALL_POS_Y

        @p2 ADDI   r8, r0, 2
        @p2 LDS.ST r8, LDS_ADDR_BALL_SIZE

        @p2 ADDI   r8, r0, 0b11
        @p2 LDS.ST r8, LDS_ADDR_BALL_MASK
        
        @p2 ADDI   r8, r0, 1
        @p2 LDS.ST r8, LDS_ADDR_BALL_DIR

        @p2 ADDI   r8, r0, 0
        @p2 LDS.ST r8, LDS_ADDR_PADDLE_POS

        @p2 ADDI   r8, r0, 6
        @p2 LDS.ST r8, LDS_ADDR_PADDLE_SIZE

        @p2 ADDI   r8, r0, 0b111_111
        @p2 LDS.ST r8, LDS_ADDR_PADDLE_MASK

        @p2 HALT 1 ; Stop early if initializing
        
    ; We know now that everything is initialized
    .gamelogic:
        LDS.LD  r8,  LDS_ADDR_BALL_POS_X
        LDS.LD  r12, LDS_ADDR_PADDLE_POS
        
        ; Check if a score happened - direction does not matter if we've reached col 0
        SEQ     r2,  r8,  r0
        .did_scored:
            ; Increment and write back
            @p2 GLOBAL.LD  r11, GLOBAL_ADDR_SCORE
            @p2 ADDI       r11, r11, 1
            @p2 GLOBAL.ST  r11, GLOBAL_ADDR_SCORE

            ; Reset ball and direction
            @p2 ADDI       r8,  r0, 1
            @p2 LDS.ST     r8, LDS_ADDR_BALL_POS_X
        
        ; TODO:
        HALT 0xFF
        .did_hit_paddle:

        .did_hit_ceiling_or_floor:

        .did_hit_right_wall:

        .didnt_hit_anything:
        
            ; TODO ONLY DO WHEN NEEDED
            LDS.LD  r9,  LDS_ADDR_BALL_POS_Y
            LDS.LD  r10, LDS_ADDR_BALL_SIZE

            LDS.LD  r12, LDS_ADDR_BALL_DIR

            LDS.LD  r13, LDS_ADDR_PADDLE_SIZE
        
        ; TODO: Check if Ball > 0
        
    
.end:
    HALT      0
        



