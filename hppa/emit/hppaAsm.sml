(*
 * This file was automatically generated by MDGen (v2.0)
 * from the machine description file "hppa/hppa.md".
 *)


functor HppaAsmEmitter(structure Instr : HPPAINSTR
                       structure Stream : INSTRUCTION_STREAM
                       structure Shuffle : HPPASHUFFLE
                          where I = Instr
                      ) : INSTRUCTION_EMITTER =
struct
   structure I  = Instr
   structure C  = I.C
   structure S  = Stream
   structure P  = S.P
   structure LabelExp = I.LabelExp
   structure Constant = I.Constant
   
   val show_cellset = MLRiscControl.getFlag "asm-show-cellset"
   val show_region  = MLRiscControl.getFlag "asm-show-region"
   val indent_copies = MLRiscControl.getFlag "asm-indent-copies"
   
   fun error msg = MLRiscErrorMsg.error("HppaAsmEmitter",msg)
   
   fun makeStream formatAnnotations =
   let val stream = !AsmStream.asmOutStream
       fun emit' s = TextIO.output(stream,s)
       val newline = ref true
       val tabs = ref 0
       fun tabbing 0 = ()
         | tabbing n = (emit' "\t"; tabbing(n-1))
       fun emit s = (tabbing(!tabs); tabs := 0; newline := false; emit' s)
       fun nl() = (tabs := 0; if !newline then () else (newline := true; emit' "\n"))
       fun comma() = emit ","
       fun tab() = tabs := 1
       fun indent() = tabs := 2
       fun ms n = let val s = Int.toString n
                  in  if n<0 then "-"^String.substring(s,1,size s-1)
                      else s
                  end
       fun emit_label lab = emit(Label.nameOf lab)
       fun emit_labexp le = emit(LabelExp.toString le)
       fun emit_const c = emit(Constant.toString c)
       fun emit_int i = emit(ms i)
       fun paren f = (emit "("; f(); emit ")")
       fun defineLabel lab = emit(Label.nameOf lab^":\n")
       fun entryLabel lab = defineLabel lab
       fun comment msg = emit("\t/* " ^ msg ^ " */")
       fun annotation a = (comment(Annotations.toString a); nl())
       fun doNothing _ = ()
       fun emit_region mem = comment(I.Region.toString mem)
       val emit_region = 
          if !show_region then emit_region else doNothing
       fun pseudoOp pOp = emit(P.toString pOp)
       fun init size = (comment("Code Size = " ^ ms size); nl())
       fun emitter regmap =
       let
           val emitRegInfo = AsmFormatUtil.reginfo
                                (emit,regmap,formatAnnotations)
   fun emit_GP r = 
       ( emit (C.showGP (regmap r)); 
       emitRegInfo r )
   and emit_FP r = 
       ( emit (C.showFP (regmap r)); 
       emitRegInfo r )
   and emit_CR r = 
       ( emit (C.showCR (regmap r)); 
       emitRegInfo r )
   and emit_CC r = 
       ( emit (C.showCC (regmap r)); 
       emitRegInfo r )
   and emit_MEM r = 
       ( emit (C.showMEM (regmap r)); 
       emitRegInfo r )
   and emit_CTRL r = 
       ( emit (C.showCTRL (regmap r)); 
       emitRegInfo r )
   
       fun emit_cellset(title,cellset) =
         (nl(); comment(title^C.cellsetToString' regmap cellset))
       val emit_cellset = 
         if !show_cellset then emit_cellset else doNothing
       fun emit_defs cellset = emit_cellset("defs: ",cellset)
       fun emit_uses cellset = emit_cellset("uses: ",cellset)
   fun asm_fmt (I.SGL) = "sgl"
     | asm_fmt (I.DBL) = "dbl"
     | asm_fmt (I.QUAD) = "quad"
   and emit_fmt x = emit (asm_fmt x)
   and asm_loadi (I.LDW) = "ldw"
     | asm_loadi (I.LDH) = "ldh"
     | asm_loadi (I.LDB) = "ldb"
   and emit_loadi x = emit (asm_loadi x)
   and asm_store (I.STW) = "stw"
     | asm_store (I.STH) = "sth"
     | asm_store (I.STB) = "stb"
   and emit_store x = emit (asm_store x)
   and asm_load (I.LDWX) = "ldwx"
     | asm_load (I.LDWX_S) = "ldwx,s"
     | asm_load (I.LDWX_M) = "ldwx,m"
     | asm_load (I.LDWX_SM) = "ldwx,sm"
     | asm_load (I.LDHX) = "ldhx"
     | asm_load (I.LDHX_S) = "ldhx,s"
     | asm_load (I.LDHX_M) = "ldhx,m"
     | asm_load (I.LDHX_SM) = "ldhx,sm"
     | asm_load (I.LDBX) = "ldbx"
     | asm_load (I.LDBX_M) = "ldbx,m"
   and emit_load x = emit (asm_load x)
   and asm_cmp (I.COMBT) = "combt"
     | asm_cmp (I.COMBF) = "combf"
   and emit_cmp x = emit (asm_cmp x)
   and asm_cmpi (I.COMIBT) = "comibt"
     | asm_cmpi (I.COMIBF) = "comibf"
   and emit_cmpi x = emit (asm_cmpi x)
   and asm_arith (I.ADD) = "add"
     | asm_arith (I.ADDL) = "addl"
     | asm_arith (I.ADDO) = "addo"
     | asm_arith (I.SH1ADD) = "sh1add"
     | asm_arith (I.SH1ADDL) = "sh1addl"
     | asm_arith (I.SH1ADDO) = "sh1addo"
     | asm_arith (I.SH2ADD) = "sh2add"
     | asm_arith (I.SH2ADDL) = "sh2addl"
     | asm_arith (I.SH2ADDO) = "sh2addo"
     | asm_arith (I.SH3ADD) = "sh3add"
     | asm_arith (I.SH3ADDL) = "sh3addl"
     | asm_arith (I.SH3ADDO) = "sh3addo"
     | asm_arith (I.SUB) = "sub"
     | asm_arith (I.SUBO) = "subo"
     | asm_arith (I.OR) = "or"
     | asm_arith (I.XOR) = "xor"
     | asm_arith (I.AND) = "and"
     | asm_arith (I.ANDCM) = "andcm"
   and emit_arith x = emit (asm_arith x)
   and asm_arithi (I.ADDI) = "addi"
     | asm_arithi (I.ADDIO) = "addio"
     | asm_arithi (I.ADDIL) = "addil"
     | asm_arithi (I.SUBI) = "subi"
     | asm_arithi (I.SUBIO) = "subio"
   and emit_arithi x = emit (asm_arithi x)
   and asm_shiftv (I.VEXTRU) = "vextru"
     | asm_shiftv (I.VEXTRS) = "vextrs"
     | asm_shiftv (I.ZVDEP) = "zvdep"
   and emit_shiftv x = emit (asm_shiftv x)
   and asm_shift (I.EXTRU) = "extru"
     | asm_shift (I.EXTRS) = "extrs"
     | asm_shift (I.ZDEP) = "zdep"
   and emit_shift x = emit (asm_shift x)
   and asm_farith (I.FADD_S) = "fadd,sgl"
     | asm_farith (I.FADD_D) = "fadd,dbl"
     | asm_farith (I.FADD_Q) = "fadd,quad"
     | asm_farith (I.FSUB_S) = "fsub,sgl"
     | asm_farith (I.FSUB_D) = "fsub,dbl"
     | asm_farith (I.FSUB_Q) = "fsub,quad"
     | asm_farith (I.FMPY_S) = "fmpy,sgl"
     | asm_farith (I.FMPY_D) = "fmpy,dbl"
     | asm_farith (I.FMPY_Q) = "fmpy,quad"
     | asm_farith (I.FDIV_S) = "fdiv,sgl"
     | asm_farith (I.FDIV_D) = "fdiv,dbl"
     | asm_farith (I.FDIV_Q) = "fdiv,quad"
     | asm_farith (I.XMPYU) = "xmpyu"
   and emit_farith x = emit (asm_farith x)
   and asm_funary (I.FCPY_S) = "fcpy,sgl"
     | asm_funary (I.FCPY_D) = "fcpy,dbl"
     | asm_funary (I.FCPY_Q) = "fcpy,quad"
     | asm_funary (I.FABS_S) = "fabs,sgl"
     | asm_funary (I.FABS_D) = "fabs,dbl"
     | asm_funary (I.FABS_Q) = "fabs,quad"
     | asm_funary (I.FSQRT_S) = "fsqrt,sgl"
     | asm_funary (I.FSQRT_D) = "fsqrt,dbl"
     | asm_funary (I.FSQRT_Q) = "fsqrt,quad"
     | asm_funary (I.FRND_S) = "frnd,sgl"
     | asm_funary (I.FRND_D) = "frnd,dbl"
     | asm_funary (I.FRND_Q) = "frnd,quad"
   and emit_funary x = emit (asm_funary x)
   and asm_fcnv (I.FCNVFF_SD) = "fcnvff,sgl,dbl"
     | asm_fcnv (I.FCNVFF_SQ) = "fcnvff,sgl,quad"
     | asm_fcnv (I.FCNVFF_DS) = "fcnvff,dbl,sgl"
     | asm_fcnv (I.FCNVFF_DQ) = "fcnvff,dbl,quad"
     | asm_fcnv (I.FCNVFF_QS) = "fcnvff,quad,sgl"
     | asm_fcnv (I.FCNVFF_QD) = "fcnvff,quad,dbl"
     | asm_fcnv (I.FCNVXF_S) = "fcnvxf,,sgl"
     | asm_fcnv (I.FCNVXF_D) = "fcnvxf,,dbl"
     | asm_fcnv (I.FCNVXF_Q) = "fcnvxf,,quad"
     | asm_fcnv (I.FCNVFX_S) = "fcnvfx,sgl,"
     | asm_fcnv (I.FCNVFX_D) = "fcnvfx,dbl,"
     | asm_fcnv (I.FCNVFX_Q) = "fcnvfx,quad,"
     | asm_fcnv (I.FCNVFXT_S) = "fcnvfxt,sgl,"
     | asm_fcnv (I.FCNVFXT_D) = "fcnvfxt,dbl,"
     | asm_fcnv (I.FCNVFXT_Q) = "fcnvfxt,quad,"
   and emit_fcnv x = emit (asm_fcnv x)
   and asm_fstore (I.FSTDS) = "fstds"
     | asm_fstore (I.FSTWS) = "fstws"
   and emit_fstore x = emit (asm_fstore x)
   and asm_fstorex (I.FSTDX) = "fstdx"
     | asm_fstorex (I.FSTDX_S) = "fstdx,s"
     | asm_fstorex (I.FSTDX_M) = "fstdx,m"
     | asm_fstorex (I.FSTDX_SM) = "fstdx,sm"
     | asm_fstorex (I.FSTWX) = "fstwx"
     | asm_fstorex (I.FSTWX_S) = "fstwx,s"
     | asm_fstorex (I.FSTWX_M) = "fstwx,m"
     | asm_fstorex (I.FSTWX_SM) = "fstwx,sm"
   and emit_fstorex x = emit (asm_fstorex x)
   and asm_floadx (I.FLDDX) = "flddx"
     | asm_floadx (I.FLDDX_S) = "flddx,s"
     | asm_floadx (I.FLDDX_M) = "flddx,m"
     | asm_floadx (I.FLDDX_SM) = "flddx,sm"
     | asm_floadx (I.FLDWX) = "fldwx"
     | asm_floadx (I.FLDWX_S) = "fldwx,s"
     | asm_floadx (I.FLDWX_M) = "fldwx,m"
     | asm_floadx (I.FLDWX_SM) = "fldwx,sm"
   and emit_floadx x = emit (asm_floadx x)
   and asm_fload (I.FLDDS) = "fldds"
     | asm_fload (I.FLDWS) = "fldws"
   and emit_fload x = emit (asm_fload x)
   and asm_bcond (I.EQ) = "="
     | asm_bcond (I.LT) = "<"
     | asm_bcond (I.LE) = "<="
     | asm_bcond (I.LTU) = "<<"
     | asm_bcond (I.LEU) = "<<="
     | asm_bcond (I.NE) = "<>"
     | asm_bcond (I.GE) = ">="
     | asm_bcond (I.GT) = ">"
     | asm_bcond (I.GTU) = ">>"
     | asm_bcond (I.GEU) = ">>="
   and emit_bcond x = emit (asm_bcond x)
   and asm_bitcond (I.BSET) = "<"
     | asm_bitcond (I.BCLR) = ">="
   and emit_bitcond x = emit (asm_bitcond x)
   and asm_fcond (I.False_) = "false?"
     | asm_fcond (I.False) = "false"
     | asm_fcond (I.?) = "?"
     | asm_fcond (I.!<=>) = "!<=>"
     | asm_fcond (I.==) = "=="
     | asm_fcond (I.EQT) = "=t"
     | asm_fcond (I.?=) = "?="
     | asm_fcond (I.!<>) = "!<>"
     | asm_fcond (I.!?>=) = "!?>="
     | asm_fcond (I.<) = "<"
     | asm_fcond (I.?<) = "?<"
     | asm_fcond (I.!>=) = "!>="
     | asm_fcond (I.!?>) = "!?>"
     | asm_fcond (I.<=) = "<="
     | asm_fcond (I.?<=) = "?<="
     | asm_fcond (I.!>) = "!>"
     | asm_fcond (I.!?<=) = "!?<="
     | asm_fcond (I.>) = ">"
     | asm_fcond (I.?>) = "?>"
     | asm_fcond (I.!<=) = "!<="
     | asm_fcond (I.!?<) = "!?<"
     | asm_fcond (I.>=) = ">="
     | asm_fcond (I.?>=) = "?>="
     | asm_fcond (I.!<) = "!<"
     | asm_fcond (I.!?=) = "!?="
     | asm_fcond (I.<>) = "<>"
     | asm_fcond (I.!=) = "!="
     | asm_fcond (I.NET) = "!=t"
     | asm_fcond (I.!?) = "!?"
     | asm_fcond (I.<=>) = "<=>"
     | asm_fcond (I.True_) = "true?"
     | asm_fcond (I.True) = "true"
   and emit_fcond x = emit (asm_fcond x)
   and emit_operand (I.REG GP) = emit "reg"
     | emit_operand (I.IMMED int) = emit_int int
     | emit_operand (I.LabExp(labexp, field_selector)) = emit_labexp labexp
     | emit_operand (I.HILabExp(labexp, field_selector)) = emit_labexp labexp
     | emit_operand (I.LOLabExp(labexp, field_selector)) = emit_labexp labexp

(*#line 638.7 "hppa/hppa.md"*)
   fun emit_n false = ()
     | emit_n true = emit ",n"

(*#line 639.7 "hppa/hppa.md"*)
   fun emit_nop false = ()
     | emit_nop true = emit "\n\tnop"
   fun emitInstr' instr = 
       (
        case instr of
        I.LOADI{li, r, i, t, mem} => 
        ( emit_loadi li; 
        emit "\t"; 
        emit_operand i; 
        emit "("; 
        emit_GP r; 
        emit "), "; 
        emit_GP t; 
        emit_region mem )
      | I.LOAD{l, r1, r2, t, mem} => 
        ( emit_load l; 
        emit "\t"; 
        emit_GP r2; 
        emit "("; 
        emit_GP r1; 
        emit "), "; 
        emit_GP t; 
        emit_region mem )
      | I.STORE{st, b, d, r, mem} => 
        ( emit_store st; 
        emit "\t"; 
        emit_GP r; 
        emit ", "; 
        emit_operand d; 
        emit "("; 
        emit_GP b; 
        emit ")"; 
        emit_region mem )
      | I.ARITH{a, r1, r2, t} => 
        ( emit_arith a; 
        emit "\t"; 
        emit_GP r1; 
        emit ", "; 
        emit_GP r2; 
        emit ", "; 
        emit_GP t )
      | I.ARITHI{ai, i, r, t} => 
        ( emit_arithi ai; 
        emit "\t"; 
        emit_operand i; 
        emit ", "; 
        emit_GP r; 
        emit ", "; 
        emit_GP t )
      | I.COMCLR_LDO{cc, r1, r2, t1, i, b, t2} => 
        (
        ( emit "comclr,"; 
        emit_bcond cc; 
        emit "\t"; 
        emit_GP r1; 
        emit ", "; 
        emit_GP r2; 
        emit ", "; 
        emit_GP t1; 
        emit "\n\t" ); 
        
        ( emit "ldo\t"; 
        emit_int i; 
        emit "("; 
        emit_GP b; 
        emit "), "; 
        emit_GP t2 ) )
      | I.COMICLR_LDO{cc, i1, r2, t1, i2, b, t2} => 
        (
        ( emit "comiclr,"; 
        emit_bcond cc; 
        emit "\t"; 
        emit_GP r2; 
        emit ", "; 
        emit_operand i1; 
        emit ", "; 
        emit_GP t1; 
        emit "\n\t" ); 
        
        ( emit "ldo\t"; 
        emit_int i2; 
        emit "("; 
        emit_GP b; 
        emit "), "; 
        emit_GP t2 ) )
      | I.SHIFTV{sv, r, len, t} => 
        ( emit_shiftv sv; 
        emit "\t"; 
        emit_GP r; 
        emit ", "; 
        emit_int len; 
        emit ", "; 
        emit_GP t )
      | I.SHIFT{s, r, p, len, t} => 
        ( emit_shift s; 
        emit "\t"; 
        emit_GP r; 
        emit ", "; 
        emit_int p; 
        emit ", "; 
        emit_int len; 
        emit ", "; 
        emit_GP t )
      | I.BCOND{cmp, bc, r1, r2, n, nop, t, f} => 
        ( emit_cmp cmp; 
        emit ","; 
        emit_bcond bc; 
        emit_n n; 
        emit "\t"; 
        emit_GP r1; 
        emit ", "; 
        emit_GP r2; 
        emit ", "; 
        emit_label t; 
        emit_nop nop )
      | I.BCONDI{cmpi, bc, i, r2, n, nop, t, f} => 
        ( emit_cmpi cmpi; 
        emit ","; 
        emit_bcond bc; 
        emit_n n; 
        emit "\t"; 
        emit_int i; 
        emit ", "; 
        emit_GP r2; 
        emit ", "; 
        emit_label t; 
        emit_nop nop )
      | I.BB{bc, r, p, n, nop, t, f} => 
        ( emit "bb,"; 
        emit_bitcond bc; 
        emit_n n; 
        emit "\t"; 
        emit_GP r; 
        emit ", "; 
        emit_int p; 
        emit ", "; 
        emit_label t; 
        emit_nop nop )
      | I.B{lab, n} => 
        ( emit "b"; 
        emit_n n; 
        emit "\t"; 
        emit_label lab )
      | I.LONGJUMP{lab, n, tmp, tmpLab} => 
        (
        ( emit "bl,n\t"; 
        emit_label tmpLab; 
        emit ", "; 
        emit_GP tmp; 
        emit "\n" ); 
        
        ( emit_label tmpLab; 
        emit ":\n\t" ); 
        
        ( emit "addil "; 
        emit_label lab; 
        emit "-("; 
        emit_label tmpLab; 
        emit "+4), "; 
        emit_GP tmp; 
        emit "\n\t" ); 
        
        ( emit "bv"; 
        emit_n n; 
        emit "\t%r0("; 
        emit_GP tmp; 
        emit ")" ) )
      | I.BE{b, d, sr, n, labs} => 
        ( emit "be"; 
        emit_n n; 
        emit "\t"; 
        emit_operand d; 
        emit "("; 
        emit_int sr; 
        emit ","; 
        emit_GP b; 
        emit ")" )
      | I.BV{x, b, labs, n} => 
        ( emit "bv"; 
        emit_n n; 
        emit "\t"; 
        emit_GP x; 
        emit "("; 
        emit_GP b; 
        emit ")" )
      | I.BLR{x, t, labs, n} => 
        ( emit "blr"; 
        emit_n n; 
        emit "\t"; 
        emit_GP x; 
        emit "("; 
        emit_GP t; 
        emit ")" )
      | I.BL{lab, t, defs, uses, mem, n} => 
        ( emit "bl"; 
        emit_n n; 
        emit "\t"; 
        emit_label lab; 
        emit ", "; 
        emit_GP t; 
        emit_region mem; 
        emit_defs defs; 
        emit_uses uses )
      | I.BLE{d, b, sr, t, defs, uses, mem} => 
        ( emit "ble\t"; 
        emit_operand d; 
        emit "("; 
        emit_int sr; 
        emit ","; 
        emit_GP b; 
        emit ")"; 
        emit_region mem; 
        emit_defs defs; 
        emit_uses uses )
      | I.LDIL{i, t} => 
        ( emit "ldil\t"; 
        emit_operand i; 
        emit ", "; 
        emit_GP t )
      | I.LDO{i, b, t} => 
        ( emit "ldo\t"; 
        emit_operand i; 
        emit "("; 
        emit_GP b; 
        emit "), "; 
        emit_GP t )
      | I.MTCTL{r, t} => 
        ( emit "mtctl\t"; 
        emit_GP r; 
        emit ", "; 
        emit_CR t )
      | I.FSTORE{fst, b, d, r, mem} => 
        ( emit_fstore fst; 
        emit "\t"; 
        emit_FP r; 
        emit ", "; 
        emit_int d; 
        emit "("; 
        emit_GP b; 
        emit ")"; 
        emit_region mem )
      | I.FSTOREX{fstx, b, x, r, mem} => 
        ( emit_fstorex fstx; 
        emit "\t"; 
        emit_FP r; 
        emit ", "; 
        emit_GP x; 
        emit "("; 
        emit_GP b; 
        emit ")"; 
        emit_region mem )
      | I.FLOAD{fl, b, d, t, mem} => 
        ( emit_fload fl; 
        emit "\t"; 
        emit_int d; 
        emit "("; 
        emit_GP b; 
        emit "), "; 
        emit_FP t; 
        emit_region mem )
      | I.FLOADX{flx, b, x, t, mem} => 
        ( emit_floadx flx; 
        emit "\t"; 
        emit_GP x; 
        emit "("; 
        emit_GP b; 
        emit "), "; 
        emit_FP t; 
        emit_region mem )
      | I.FARITH{fa, r1, r2, t} => 
        ( emit_farith fa; 
        emit "\t"; 
        emit_FP r1; 
        emit ", "; 
        emit_FP r2; 
        emit ", "; 
        emit_FP t )
      | I.FUNARY{fu, f, t} => 
        ( emit_funary fu; 
        emit "\t"; 
        emit_FP f; 
        emit ", "; 
        emit_FP t )
      | I.FCNV{fcnv, f, t} => 
        ( emit_fcnv fcnv; 
        emit "\t"; 
        emit_FP f; 
        emit ", "; 
        emit_FP t )
      | I.FBRANCH{cc, fmt, f1, f2, t, f, n, long} => 
        (
        ( emit "fcmp,"; 
        emit_fmt fmt; 
        emit ","; 
        emit_fcond cc; 
        emit "\t"; 
        emit_FP f1; 
        emit ", "; 
        emit_FP f2; 
        emit "\n\t" ); 
        emit "ftest\n\t"; 
        
        ( emit "b"; 
        emit_n n; 
        emit "\t"; 
        emit_label t ) )
      | I.BREAK{code1, code2} => 
        ( emit "break\t"; 
        emit_int code1; 
        emit ", "; 
        emit_int code2 )
      | I.NOP => emit "nop"
      | I.COPY{dst, src, impl, tmp} => emitInstrs (Shuffle.shuffle {regmap=regmap, tmp=tmp, src=src, dst=dst})
      | I.FCOPY{dst, src, impl, tmp} => emitInstrs (Shuffle.shufflefp {regmap=regmap, tmp=tmp, src=src, dst=dst})
      | I.ANNOTATION{i, a} => 
        ( emitInstr i; 
        comment (Annotations.toString a))
       )
          and emitInstr i = (tab(); emitInstr' i; nl())
          and emitInstrIndented i = (indent(); emitInstr' i; nl())
          and emitInstrs instrs =
           app (if !indent_copies then emitInstrIndented
                else emitInstr) instrs
      in  emitInstr end
   
   in  S.STREAM{beginCluster=init,
                pseudoOp=pseudoOp,
                emit=emitter,
                endCluster=doNothing,
                defineLabel=defineLabel,
                entryLabel=entryLabel,
                comment=comment,
                exitBlock=doNothing,
                annotation=annotation,
                phi=doNothing,
                alias=doNothing
               }
   end
end

