; ============================================================================
; GPU ISA v2 - CustomASM Definition
; ============================================================================
#once

#bankdef memory_instruction
{
    bits = 32
    addr = 0x0000
    outp = 0
}

; #bankdef memory_lds
; {
;     bits = 32
;     addr = 0x0000
;     outp = 0
;     ; size = 0x4000
; }
; 
; #bankdef memory_global
; {
;     bits = 32
;     addr = 0x0000
;     outp = 0
;     ; size = 0x8000
; }

; ============================================================================
; SUBRULE DEFINITIONS
; ============================================================================

; Register definitions
#subruledef reg {
    ; First four registers can be used as predicate registers
    p0  => 0x00`5
    p1  => 0x01`5
    p2  => 0x02`5
    p3  => 0x03`5

    ; Note that r0 is constant zero
    r0  => 0x00`5
    r1  => 0x01`5
    r2  => 0x02`5
    r3  => 0x03`5
    r4  => 0x04`5
    r5  => 0x05`5
    r6  => 0x06`5
    r7  => 0x07`5
    r8  => 0x08`5
    r9  => 0x09`5
    r10 => 0x0A`5
    r11 => 0x0B`5
    r12 => 0x0C`5
    r13 => 0x0D`5
    r14 => 0x0E`5
    r15 => 0x0F`5
    r16 => 0x10`5
    r17 => 0x11`5
    r18 => 0x12`5
    r19 => 0x13`5
    r20 => 0x14`5
    r21 => 0x15`5
    r22 => 0x16`5
    r23 => 0x17`5
    r24 => 0x18`5
    r25 => 0x19`5
    r26 => 0x1A`5
    r27 => 0x1B`5
    r28 => 0x1C`5
    r29 => 0x1D`5
    r30 => 0x1E`5
    r31 => 0x1F`5
}

; Predicate definitions
#subruledef pred {
    ; Using the GPR name
    ; RESERVED: @r0  => 0b000`3
    @r1  => 0b001`3
    @r2  => 0b010`3
    @r3  => 0b011`3
    ; RESERVED: @!r0 => 0b100`3
    @!r1 => 0b101`3
    @!r2 => 0b110`3
    @!r3 => 0b111`3

    ; Using the predicate name
    ; RESERVED: @p0  => 0b000`3
    @p1  => 0b001`3
    @p2  => 0b010`3
    @p3  => 0b011`3
    ; RESERVED: @!p0 => 0b100`3
    @!p1 => 0b101`3
    @!p2 => 0b110`3
    @!p3 => 0b111`3
    
    ; Special name for always
    @true  => 0b000`3
}

; 11-bit signed immediate for mem offsets
; 11-bit signed immediate for ALU Imm instructions
#subruledef imm11 {
    {value: i11} => value`11
}

; 15-bit unsigned immediate for system instructions
#subruledef imm15 {
    {value: u15} => value`15
}

; 16-bit unsigned immediate for L?I instructions
#subruledef imm16 {
    {value: i16} => value`16
}

; 21-bit signed immediate for JP instruction
#subruledef imm21 {
    {value: i21} => value`21
}

; 21-bit signed immediate (for jumps)
; #subruledef imm21 {
;     {value: i21} => value`21
; }

; 6-bit shift amount
; #subruledef shamt {
;     {value: u6} => value`6
; }

; LEA scale
; #subruledef lea_scale {
;     1 => 0b00
;     2 => 0b01
;     4 => 0b10
;     8 => 0b11
; }

; ; LEA offset
; #subruledef lea_offset {
;     {value: i4} => value`4
; }

#subruledef mem_module {
    GLOBAL => 0b00`2
    LDS    => 0b01`2
    ; Exposed via special instructions
    ; SR     => 0b11`2
}

#subruledef mem_width {
    b4  => 0b00`2
    b2  => 0b01`2
    b1  => 0b11`2
}

#subruledef simd_mode {
    1x32 => 0b00`2
    2x16 => 0b01`2
    4x8  => 0b10`2
}

#subruledef special_registers {
    ; TODO: Alignment is probably off? DW alignment?
    ; TODO: Missing TID, NTID, BID, NBID
    lane  => 0x10`11 ; Lane ID
    pc    => 0x12`11 ; Program Counter
    rdtsc => 0x14`11 ; Cycle Counter
    arg0  => 0x18`11 ; Argument to kernel
    arg1  => 0x19`11 ; 
    arg2  => 0x1a`11 ; 
    arg3  => 0x1b`11 ; 
    arg4  => 0x1c`11 ; 
    arg5  => 0x1d`11 ; 
    arg6  => 0x1e`11 ; 
    arg7  => 0x1f`11 ; 
}

; ============================================================================
; INSTRUCTION RULEDEF
; ============================================================================

#ruledef {
    ; ========================================================================
    ; INTEGER ALU WITH PACKING
    ; ========================================================================
    ; Page 0: Standard =======================================================

    ; ADD - alu_func4 = 0 - alu_func3 = 0
    {p: pred} ADD.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x0`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x0`4 @ m
              ADD.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true ADD.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} ADD                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   ADD.1x32 {rd}, {rs1}, {rs2}}
              ADD                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true ADD.1x32 {rd}, {rs1}, {rs2}} 

    ; AND - alu_func4 = 0 - alu_func3 = 1
    {p: pred} AND.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x1`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x0`4 @ m
              AND.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true AND.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} AND                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   AND.1x32 {rd}, {rs1}, {rs2}}
              AND                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true AND.1x32 {rd}, {rs1}, {rs2}} 

    ; OR  - alu_func4 = 0 - alu_func3 = 2
    {p: pred} OR.{m: simd_mode}  {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x2`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x0`4 @ m
              OR.{m: simd_mode}  {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true OR.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} OR                 {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   OR.1x32 {rd}, {rs1}, {rs2}}
              OR                 {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true OR.1x32 {rd}, {rs1}, {rs2}} 

    ; XOR - alu_func4 = 0 - alu_func3 = 3
    {p: pred} XOR.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x3`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x0`4 @ m
              XOR.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true XOR.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} XOR                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   XOR.1x32 {rd}, {rs1}, {rs2}}
              XOR                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true XOR.1x32 {rd}, {rs1}, {rs2}} 

    ; SLL - alu_func4 = 0 - alu_func3 = 5
    {p: pred} SLL.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x5`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x0`4 @ m
              SLL.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SLL.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} SLL                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SLL.1x32 {rd}, {rs1}, {rs2}}
              SLL                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SLL.1x32 {rd}, {rs1}, {rs2}} 

    ; SRL - alu_func4 = 0 - alu_func3 = 5
    {p: pred} SRL.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x6`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x0`4 @ m
              SRL.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SRL.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} SRL                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SRL.1x32 {rd}, {rs1}, {rs2}}
              SRL                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SRL.1x32 {rd}, {rs1}, {rs2}} 

    ; SRA - alu_func4 = 0 - alu_func3 = 5
    {p: pred} SRA.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x7`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x0`4 @ m
              SRA.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SRA.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} SRA                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SRA.1x32 {rd}, {rs1}, {rs2}}
              SRA                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SRA.1x32 {rd}, {rs1}, {rs2}} 

    ; Page 1: Extended A =====================================================

    ; SUB - alu_func4 = 1 - alu_func3 = 0
    {p: pred} SUB.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x0`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x1`4 @ m
              SUB.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SUB.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} SUB                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SUB.1x32 {rd}, {rs1}, {rs2}}
              SUB                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SUB.1x32 {rd}, {rs1}, {rs2}} 

    ; Page 2: Extended B =====================================================

    ; SEQ - alu_func4 = 2 - alu_func3 = 4
    {p: pred} SEQ.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x4`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x2`4 @ m
              SEQ.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SEQ.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} SEQ                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SEQ.1x32 {rd}, {rs1}, {rs2}}
              SEQ                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SEQ.1x32 {rd}, {rs1}, {rs2}} 

    ; SLT - alu_func4 = 2 - alu_func3 = 5
    {p: pred} SLT.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => 0x00`5 @ 0x5`3 @ p`3     @ rd @ rs1 @ rs2 @ 0x2`4 @ m
              SLT.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SLT.{m}  {rd}, {rs1}, {rs2}}
    {p: pred} SLT                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SLT.1x32 {rd}, {rs1}, {rs2}}
              SLT                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SLT.1x32 {rd}, {rs1}, {rs2}} 

    ; TODO: Remaining instructions

    ; ========================================================================
    ; INTEGER ALU WITH IMMEDIATES
    ; ========================================================================
    ; Note that alu_func4 is always 0 and alu_func3 reuses the mapping above
    ; ========================================================================

    ; ADD - alu_func3 = 0
    {p: pred} ADDI {rd: reg}, {rs1: reg}, {imm: imm11} => 0x01`5 @ 0x0`3 @ p       @ rd @ rs1 @ imm
              ADDI {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true ADDI {rd}, {rs1}, {imm} }

    ; AND - alu_func3 = 1
    {p: pred} ANDI {rd: reg}, {rs1: reg}, {imm: imm11} => 0x01`5 @ 0x1`3 @ p       @ rd @ rs1 @ imm
              ANDI {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true ANDI {rd}, {rs1}, {imm} }

    ; OR  - alu_func3 = 2
    {p: pred} ORI  {rd: reg}, {rs1: reg}, {imm: imm11} => 0x01`5 @ 0x2`3 @ p       @ rd @ rs1 @ imm
              ORI  {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true ORI  {rd}, {rs1}, {imm} }

    ; XOR  - alu_func3 = 3
    {p: pred} XORI {rd: reg}, {rs1: reg}, {imm: imm11} => 0x01`5 @ 0x3`3 @ p       @ rd @ rs1 @ imm
              XORI {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true XORI {rd}, {rs1}, {imm} }

    ; UNUSED  - alu_func3 = 4

    ; SLL  - alu_func3 = 5
    {p: pred} SLLI {rd: reg}, {rs1: reg}, {imm: imm11} => 0x01`5 @ 0x5`3 @ p       @ rd @ rs1 @ imm
              SLLI {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true XORI {rd}, {rs1}, {imm} }

    ; SRL  - alu_func3 = 5
    {p: pred} SRLI {rd: reg}, {rs1: reg}, {imm: imm11} => 0x01`5 @ 0x6`3 @ p       @ rd @ rs1 @ imm
              SRLI {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true XORI {rd}, {rs1}, {imm} }

    ; SRA  - alu_func3 = 5
    {p: pred} SRAI {rd: reg}, {rs1: reg}, {imm: imm11} => 0x01`5 @ 0x7`3 @ p       @ rd @ rs1 @ imm
              SRAI {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true XORI {rd}, {rs1}, {imm} }

    ; ========================================================================
    ; INTEGER ALU SPECIAL FUNCTIONS
    ; ========================================================================

    ; TODO: Remaining instructions: FMA, LEA

    ; LLI  - alu_func3 = 3
    {p: pred} LLI {rd: reg}, {imm: imm16} => 0x1C`8 @ p       @ rd @ imm
              LLI {rd: reg}, {imm: imm16} => asm { @true LLI {rd}, {imm} }

    ; LUI  - alu_func3 = 3
    {p: pred} LUI {rd: reg}, {imm: imm16} => 0x1D`8 @ p       @ rd @ imm
              LUI {rd: reg}, {imm: imm16} => asm { @true LUI {rd}, {imm} }

    ; ========================================================================
    ; IO - LOADS
    ; ========================================================================
    {p: pred} {m: mem_module}.LD.{w: mem_width} {rd: reg}, {rs1: reg}, {imm: imm11} => 0x8`4 @ m @ w      @ p       @ rd @ rs1 @ imm
              {m: mem_module}.LD.{w: mem_width} {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true {m}.LD.{w} {rd}, {rs1}, {imm} }
    {p: pred} {m: mem_module}.LD                {rd: reg}, {rs1: reg}, {imm: imm11} => asm { {p}   {m}.LD.B4  {rd}, {rs1}, {imm} }
              {m: mem_module}.LD                {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true {m}.LD.B4  {rd}, {rs1}, {imm} }
    {p: pred}              SR.LD                {rd: reg}, {rs1: reg}              => 0x8`4 @ 0b11`2 @ 0b00`2 @ p  @ rd @ rs1 @ 0b0`11
                           SR.LD                {rd: reg}, {rs1: reg}              => asm { @true SR.LD  {rd}, {rs1} }
    {p: pred}              SR.LD                {rd: reg}, {sr: special_registers} => 0x8`4 @ 0b11`2 @ 0b00`2 @ p  @ rd @ 0b0`5 @ sr
                           SR.LD                {rd: reg}, {sr: special_registers} => asm { @true SR.LD  {rd}, {sr} }

    ; ========================================================================
    ; IO - STORES
    ; ========================================================================
    {p: pred} {m: mem_module}.ST.{w: mem_width} {rd: reg}, {rs1: reg}, {imm: imm11} => 0x9`4 @ m @ w      @ p       @ rd @ rs1 @ imm
              {m: mem_module}.ST.{w: mem_width} {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true {m}.ST.{w} {rd}, {rs1}, {imm} }
    {p: pred} {m: mem_module}.ST                {rd: reg}, {rs1: reg}, {imm: imm11} => asm { {p}   {m}.ST.B4  {rd}, {rs1}, {imm} }
              {m: mem_module}.ST                {rd: reg}, {rs1: reg}, {imm: imm11} => asm { @true {m}.ST.B4  {rd}, {rs1}, {imm} }
    {p: pred}              SR.ST                {rd: reg}, {rs1: reg}              => 0x9`4 @ 0b11`2 @ 0b00`2 @ p  @ rd @ rs1 @  0b0`11
                           SR.ST                {rd: reg}, {rs1: reg}              => asm { @true SR.ST  {rd}, {rs1} }
    {p: pred}              SR.ST                {rd: reg}, {sr: special_registers} => 0x9`4 @ 0b11`2 @ 0b00`2 @ p  @ rd @ 0b0`5 @ imm
                           SR.ST                {rd: reg}, {sr: special_registers} => asm { @true SR.ST  {rd}, {sr} }

    ; TODO: Syntactic surgar to set rs1 to r0 if module is SR. Also add special names for e.g. TID.X, ..
    ; TODO: Move syntactic sugar to mnemonics and reuse the full template for easy maintainability

    ; ========================================================================
    ; SYS - JP
    ; ========================================================================
    {p: pred} JP.REL {rel_addr: imm21} => 0xC2`8 @ p       @ rel_addr
              JP.REL {rel_addr: u21}   => asm { @true JP.REL {rel_addr} }

    {p: pred} JP.ABS {abs_addr: u20} => {
        rel_addr = abs_addr - $
        ; TODO: Assert that abs_addr is valid! That means that $ is within range
        ; assert(1 >= 0)
        asm { {p} JP.REL {rel_addr} }
    }
              JP.ABS {abs_addr: u21} => asm { @true JP.ABS {abs_addr} }


    ; ========================================================================
    ; SYS - Controls
    ; ========================================================================
              NOP  {imm: imm15} => 0xFF`8 @ 0b000`3 @ imm @ 0b000000`6
    {p: pred} NOP  {imm: imm15} => 0xFF`8 @ p       @ imm @ 0b000000`6

              HALT {imm: imm15} => 0xFF`8 @ 0b000`3 @ imm @ 0b111111`6
    {p: pred} HALT {imm: imm15} => 0xFF`8 @ p       @ imm @ 0b111111`6

    ; TODO: Remaining instructions
    ; TODO: Make immediates more meaningful and enforce instruction specific limits. E.g. NOP can't set 21 bits

    ; <--------------------------------- PTR ------------------------------------>

    ; 
    ; ; ========================================================================
    ; ; EXTENDED OPERATIONS (func[3:0] != 0)
    ; ; ========================================================================
    ; 
    ; ; HADD variants
    ; HADD {rd: reg}, {rs1: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ 0b00000 @ 0b00`2 @ 0x5`4
    ; {p: pred} HADD {rd: reg}, {rs1: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ 0b00000 @ 0b00`2 @ 0x5`4
    ; 
    ; HADD.2x16 {rd: reg}, {rs1: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ 0b00000 @ 0b01`2 @ 0x5`4
    ; {p: pred} HADD.2x16 {rd: reg}, {rs1: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ 0b00000 @ 0b01`2 @ 0x5`4
    ; 
    ; HADD.4x8 {rd: reg}, {rs1: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ 0b00000 @ 0b10`2 @ 0x5`4
    ; {p: pred} HADD.4x8 {rd: reg}, {rs1: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ 0b00000 @ 0b10`2 @ 0x5`4
    ; 
    ; ; BROADCAST variants
    ; BROADCAST {rd: reg}, {rs1: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ 0b00000 @ 0b00`2 @ 0xD`4
    ; {p: pred} BROADCAST {rd: reg}, {rs1: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ 0b00000 @ 0b00`2 @ 0xD`4
    ; 
    ; BROADCAST.2x16 {rd: reg}, {rs1: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ 0b00000 @ 0b01`2 @ 0xD`4
    ; {p: pred} BROADCAST.2x16 {rd: reg}, {rs1: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ 0b00000 @ 0b01`2 @ 0xD`4
    ; 
    ; BROADCAST.4x8 {rd: reg}, {rs1: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ 0b00000 @ 0b10`2 @ 0xD`4
    ; {p: pred} BROADCAST.4x8 {rd: reg}, {rs1: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ 0b00000 @ 0b10`2 @ 0xD`4
    ; 
    ; ; RGB565 operations
    ; RGB565.PACK {rd: reg}, {rs1: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ 0b00000 @ 0b00`2 @ 0x8`4
    ; {p: pred} RGB565.PACK {rd: reg}, {rs1: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ 0b00000 @ 0b00`2 @ 0x8`4
    ; 
    ; RGB565.UNPACK {rd: reg}, {rs1: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ 0b00000 @ 0b00`2 @ 0x9`4
    ; {p: pred} RGB565.UNPACK {rd: reg}, {rs1: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ 0b00000 @ 0b00`2 @ 0x9`4
    ; 
    ; RGB565.SCALE {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0xB`4
    ; {p: pred} RGB565.SCALE {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0xB`4
    ; 
    ; ; DOT product variants
    ; DOT.4x8 {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x00 @ 0b000 @ rd`5 @ rs1`5 @ rs2`5 @ 0b10`2 @ 0xE`4
    ; {p: pred} DOT.4x8 {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x00 @ p`3 @ rd`5 @ rs1`5 @ rs2`5 @ 0b10`2 @ 0xE`4
    ; 
    ; ; ========================================================================
    ; ; INTEGER I-TYPE (0x20-0x3F)
    ; ; ========================================================================
    ; 
    ; ; LEA
    ; LEA {rd: reg}, {rs1: reg}, {rs2: reg}, {scale: lea_scale}, {offset: lea_offset}
    ;     => 0x3A @ 0b000 @ rd`5 @ rs1`5 @ rs2`5 @ scale`2 @ offset
    ; {p: pred} LEA {rd: reg}, {rs1: reg}, {rs2: reg}, {scale: lea_scale}, {offset: lea_offset}
    ;     => 0x3A @ p`3 @ rd`5 @ rs1`5 @ rs2`5 @ scale`2 @ offset
    ; 
    ; ; ========================================================================
    ; ; COMPARISON (0x80-0x86)
    ; ; ========================================================================
    ; 
    ; ; SEQ - Set if equal
    ; SEQ {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x80 @ 0b000 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0x0`4
    ; {p: pred} SEQ {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x80 @ p`3 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0x0`4
    ; 
    ; ; SLT - Set if less than (signed)
    ; SLT {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x82 @ 0b000 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0x0`4
    ; {p: pred} SLT {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x82 @ p`3 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0x0`4
    ; 
    ; ; FEQ - Floating-point equal
    ; FEQ {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x85 @ 0b000 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0x0`4
    ; {p: pred} FEQ {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x85 @ p`3 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0x0`4
    ; 
    ; ; FLT - Floating-point less than
    ; FLT {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x86 @ 0b000 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0x0`4
    ; {p: pred} FLT {rd: reg}, {rs1: reg}, {rs2: reg}
    ;     => 0x86 @ p`3 @ rd`5 @ rs1`5 @ rs2`5 @ 0b00`2 @ 0x0`4
    ; 
    ; ; ========================================================================
    ; ; FLOATING POINT
    ; ; ========================================================================
    ;
    ; ; ========================================================================
    ; ; CONTROL FLOW (0xC0-0xDF)
    ; ; ========================================================================
    ; 
    ; BEQ {rs1: reg}, {rs2: reg}, {offset: imm12}
    ;     => 0xC0 @ 0b000 @ rs1`5 @ rs2`5 @ offset
    ; {p: pred} BEQ {rs1: reg}, {rs2: reg}, {offset: imm12}
    ;     => 0xC0 @ p`3 @ rs1`5 @ rs2`5 @ offset
    ; 
    ; BNE {rs1: reg}, {rs2: reg}, {offset: imm12}
    ;     => 0xC1 @ 0b000 @ rs1`5 @ rs2`5 @ offset
    ; {p: pred} BNE {rs1: reg}, {rs2: reg}, {offset: imm12}
    ;     => 0xC1 @ p`3 @ rs1`5 @ rs2`5 @ offset
    ; 
    ; JUMP {offset: imm21}
    ;     => 0xC8 @ 0b000 @ offset
    ; {p: pred} JUMP {offset: imm21}
    ;     => 0xC8 @ p`3 @ offset
    ; 
    ; RET
    ;     => 0xCB @ 0b000 @ 0`21
    ; {p: pred} RET
    ;     => 0xCB @ p`3 @ 0`21
    ; 
    ; ; ========================================================================
    ; ; SYSTEM (0xF0-0xFF)
    ; ; ========================================================================
    ; 
    ; NOP
    ;     => 0xF0 @ 0b000 @ 0`21
}
