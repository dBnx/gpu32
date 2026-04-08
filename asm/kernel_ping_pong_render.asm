
#include "lib/gpu32-isa.asm"
#include "lib/gpu32-lib.asm"

#const LDS_ADDR_BALL_POS_X  0x0000
#const LDS_ADDR_BALL_POS_Y  0x0004
#const LDS_ADDR_BALL_SIZE   0x0008
#const LDS_ADDR_BALL_MASK   0x0010

#const LDS_ADDR_PADDLE_POS  0x0020
#const LDS_ADDR_PADDLE_SIZE 0x0024
#const LDS_ADDR_PADDLE_MASK 0x0024

entry:
    ; Preparation:
    ZERO    r4             ; 'Rendered' 32b mask to be stored
    ZERO    r5             ; wg.x
    SR.LD   r5,  wg.x

    ; |r4: r2, r14, r15, r16, r17, r18
    .render_left_paddle:
        ; r2: - Predicate if wg.x 0
        SEQ     r2,  r0, r5  

        ; |r4: r14, r15, r16 - Render paddle
        @p2 LDS.LD  r15, LDS_ADDR_PADDLE_POS
        @p2 LDS.LD  r16, LDS_ADDR_PADDLE_SIZE
        @p2 LDS.LD  r17, LDS_ADDR_PADDLE_MASK
        @p2 SLL     r14, r17, r15              ; Adjust paddle position
        @p2 OR      r4,  r4,  r14              ; Add rendered bitmask to r4

    ; |r4: r2, r14, r15, r16, r17
    .render_ball:

        ; r2: r14, r15, r16, r17 - Check if there is an overlap
        LDS.LD  r14, LDS_ADDR_BALL_POS_X     ; 14 -> X min
        LDS.LD  r17, LDS_ADDR_BALL_SIZE      ; 16 -> Ball size
        ADD     r15, r14, r17                ; 15 -> X max
        SLT     r2,  r4,  r14
        SGT     r15, r4,  r15
        OR      r2,  r2,  r15                ; X is within Ball range

        ; |r4: (r2), r16, r18 - Render ball - We know now that we are within the ball-range x wise
        @p2 LDS.LD  r16, LDS_ADDR_BALL_POS_Y ; 16 -> Y min
        @p2 LDS.LD  r18, LDS_ADDR_BALL_MASK  ; TODO
        @p2 SLL     r15, r18, r16            ; Adjust ball position
        @p2 OR      r4,  r4,  r15
    
    .store_pixel:
        ; We directly store to wg.x, so nothing to do
        GLOBAL.ST r5, r4, 0
    
.end:
    HALT      0
        



