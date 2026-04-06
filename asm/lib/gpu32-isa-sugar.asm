#once
#include "gpu32-isa-base.asm"

#ruledef {
    ; ========================================================================
    ; ARITH HELPERS
    ; ========================================================================
    {p: pred} ZERO {rd: reg} => asm { {p}   ADDI  {rd}, r0, 0 }
              ZERO {rd: reg} => asm { @true ZERO {rd} }

    {p: pred} SWAP {ra: reg}, {rb: reg} => asm {
                                                {p}   XOR   {ra}, {ra}, {rb} 
                                                {p}   XOR   {rb}, {ra}, {rb} 
                                                {p}   XOR   {ra}, {ra}, {rb} 
                                               }
              SWAP {ra: reg}, {rb: reg} => asm { @true SWAP {ra}, {rb} }

    ; Set if equal zero
    {p: pred} SEZ                {rd: reg}, {rs1: reg} => asm { {p}   SEQ.1x32 {rd}, {rs1}, r0}
              SEZ                {rd: reg}, {rs1: reg} => asm { @true SEQ.1x32 {rd}, {rs1}, r0} 

    ; ========================================================================
    ; LOAD IMMEDIATE HELPERS
    ; ========================================================================

    ; BYTES ==================================================================
    {p: pred} LI.B0 {rd: reg}, {imm: u8} => asm { {p}   LLI  {rd}, {imm} }
              LI.B0 {rd: reg}, {imm: u8} => asm { @true LI.B0 {rd}, {imm} }
    {p: pred} LI.B1 {rd: reg}, {imm: u8} => { 
                                                imm_shifted = imm << 8
                                                asm { {p} LLI {rd}, {imm_shifted} } 
                                           }
              LI.B1 {rd: reg}, {imm: u8} => asm { @true LI.B1 {rd}, {imm} }

    {p: pred} LI.B2 {rd: reg}, {imm: u8} => asm { {p}   LLI  {rd}, {imm} }
              LI.B2 {rd: reg}, {imm: u8} => asm { @true LI.B2 {rd}, {imm} }
    {p: pred} LI.B3 {rd: reg}, {imm: u8} => { 
                                                imm_shifted = imm << 8
                                                asm { {p} LUI {rd}, {imm_shifted} } 
                                           }
              LI.B3 {rd: reg}, {imm: u8} => asm { @true LI.B3 {rd}, {imm} }

    ; WORDS ==================================================================
    {p: pred} LI.W0 {rd: reg}, {imm: u16} => asm { {p}   LLI   {rd}, {imm} }
              LI.W0 {rd: reg}, {imm: u16} => asm { @true LI.W0 {rd}, {imm} }
    {p: pred} LI.W1 {rd: reg}, {imm: u16} => asm { {p}   LUI   {rd}, {imm} }
              LI.W1 {rd: reg}, {imm: u16} => asm { @true LI.W1 {rd}, {imm} }

    ; DWRODS =================================================================
    {p: pred} LI.DW0 {rd: reg}, {imm: u32} => {
                                                ; TODO: Optimize if imm is 16b
                                                ; TODO: Assert pred != rd
                                                assert(p != rd, "Predicate may not be the target")
                                                imm_low = imm`16
                                                imm_high = imm >> 32
                                                asm {
                                                    {p}   LLI   {rd}, {imm_low} 
                                                    {p}   LUI   {rd}, {imm_high} 
                                                }
                                              }
              LI.DW0 {rd: reg}, {imm: u32} => asm { @true LI.DW0 {rd}, {imm} }

    ; REG SIZE ===============================================================
    {p: pred} LI     {rd: reg}, {imm: u32} => asm { {p}   LI.DW0 {rd}, {imm} }
              LI     {rd: reg}, {imm: u32} => asm { @true LI.DW0 {rd}, {imm} }

    ; ========================================================================
    ; ..
    ; ========================================================================
}