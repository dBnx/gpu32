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

    {p: pred} INV                {rd: reg}, {rs1: reg} => asm { {p}   XORI.1x32 {rd}, {rs1}, -1}
              INV                {rd: reg}, {rs1: reg} => asm { @true INV       {rd}, {rs1}} 

    ; Set Equal Zero
    {p: pred} SEZ                {rd: reg}, {rs1: reg} => asm { {p}   SEQ.1x32 {rd}, {rs1}, r0}
              SEZ                {rd: reg}, {rs1: reg} => asm { @true SEQ.1x32 {rd}, {rs1}, r0} 
    ; Set Not Equal Zero
    ; {p: pred} SNZ                {rd: reg}, {rs1: reg} => asm { {p}   SLT.1x32 {rd}, {rs1}, }
    ;           SNZ                {rd: reg}, {rs1: reg} => asm { @true SLT.1x32 {rd}, {rs1}, } 

    ; Set Greater Equal - Swap rs1 and rs2 in SLT for convinience
    {p: pred} SGE.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SLT.{m}  {rd}, {rs2}, {rs1}}
              SGE.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SLT.{m}  {rd}, {rs2}, {rs1}}
    {p: pred} SGE                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SLT.1x32 {rd}, {rs2}, {rs1}}
              SGE                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SLT.1x32 {rd}, {rs2}, {rs1}} 

    ; Set Greater Than - Swap rs1 and rs2 in SLE for convinience
    {p: pred} SGT.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SLE.{m}  {rd}, {rs2}, {rs1}}
              SGT.{m: simd_mode} {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SLE.{m}  {rd}, {rs2}, {rs1}}
    {p: pred} SGT                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { {p}   SLE.1x32 {rd}, {rs2}, {rs1}}
              SGT                {rd: reg}, {rs1: reg}, {rs2: reg} => asm { @true SLE.1x32 {rd}, {rs2}, {rs1}} 

    ; ========================================================================
    ; LOAD IMMEDIATE HELPERS
    ; ========================================================================

    ; BYTES ==================================================================
    {p: pred} LI.B0 {rd: reg}, {imm: u8} => asm { {p}   LLI.01  {rd}, {imm} }
              LI.B0 {rd: reg}, {imm: u8} => asm { @true LI.B0 {rd}, {imm} }
    {p: pred} LI.B1 {rd: reg}, {imm: u8} => { 
                                                imm_shifted = imm << 8
                                                asm { {p} LLI.10 {rd}, {imm_shifted} } 
                                           }
              LI.B1 {rd: reg}, {imm: u8} => asm { @true LI.B1 {rd}, {imm} }

    {p: pred} LI.B2 {rd: reg}, {imm: u8} => asm { {p}   LUI.01  {rd}, {imm} }
              LI.B2 {rd: reg}, {imm: u8} => asm { @true LI.B2 {rd}, {imm} }
    {p: pred} LI.B3 {rd: reg}, {imm: u8} => { 
                                                imm_shifted = imm << 8
                                                asm { {p} LUI.10 {rd}, {imm_shifted} } 
                                           }
              LI.B3 {rd: reg}, {imm: u8} => asm { @true LI.B3 {rd}, {imm} }

    ; WORDS ==================================================================
    {p: pred} LI.W0 {rd: reg}, {imm: u16} => asm { {p}   LLI.11 {rd}, {imm} }
              LI.W0 {rd: reg}, {imm: u16} => asm { @true LI.W0  {rd}, {imm} }
    {p: pred} LI.W1 {rd: reg}, {imm: u16} => asm { {p}   LUI.11 {rd}, {imm} }
              LI.W1 {rd: reg}, {imm: u16} => asm { @true LI.W1  {rd}, {imm} }

    ; DWRODS =================================================================
    {p: pred} LI.DW0 {rd: reg}, {imm: u32} => {
                                                ; TODO: Optimize if imm is 16b
                                                ; TODO: Assert pred != rd
                                                assert(p != rd, "Predicate may not be the target")
                                                imm_low = imm`16
                                                imm_high = imm >> 16
                                                asm {
                                                    {p}   LLI.11   {rd}, {imm_low} 
                                                    {p}   LUI.11   {rd}, {imm_high} 
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