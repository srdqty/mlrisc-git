(*
 * This is a generic module for transforming MLTREE expressions:
 *   (1) expressions involving non-standard type widths are promoted when
 *       necessary.
 *   (2) operators that cannot be directly handled are expanded into 
 *       more complex instruction sequences when necessary.
 * 
 * -- Allen
 *)

functor MLTreeGen
    (structure T : MLTREE
     val intTy : T.ty (* size of integer word *)

     (* This is a list of possible data widths to promote to.
      * The list must be in increasing sizes.  
      * We'll try to promote to the next largest size.
      *)
     val naturalWidths : T.ty list  

     (*
      * Are integers of widths less than the size of integer word.
      * automatically sign extended, zero extended, or neither.
      * When in doubt, choose neither since it is conservative.
      *)
     datatype rep = SE | ZE | NEITHER
     val rep : rep

    ) : MLTREEGEN =
struct

   structure T = T
   structure LE = T.LabelExp

   exception SizeUnknown

   exception Unsupported of string

   fun error msg = MLRiscErrorMsg.error("MLTreeGen",msg)

   fun size(T.REG(ty,_)) = ty
     | size(T.LI _) = intTy
     | size(T.LI32 _) = intTy
     | size(T.LI64 _) = intTy
     | size(T.LABEL _) = intTy
     | size(T.CONST _) = intTy
     | size(T.NEG(ty,_)) = ty
     | size(T.ADD(ty,_,_)) = ty
     | size(T.SUB(ty,_,_)) = ty
     | size(T.MULS(ty,_,_)) = ty
     | size(T.DIVS(ty,_,_)) = ty
     | size(T.QUOTS(ty,_,_)) = ty
     | size(T.REMS(ty,_,_)) = ty
     | size(T.MULU(ty,_,_)) = ty
     | size(T.DIVU(ty,_,_)) = ty
     | size(T.REMU(ty,_,_)) = ty
     | size(T.NEGT(ty,_)) = ty
     | size(T.ADDT(ty,_,_)) = ty
     | size(T.SUBT(ty,_,_)) = ty
     | size(T.MULT(ty,_,_)) = ty
     | size(T.DIVT(ty,_,_)) = ty
     | size(T.QUOTT(ty,_,_)) = ty
     | size(T.REMT(ty,_,_)) = ty
     | size(T.ANDB(ty,_,_)) = ty
     | size(T.ORB(ty,_,_)) = ty
     | size(T.XORB(ty,_,_)) = ty
     | size(T.NOTB(ty,_)) = ty
     | size(T.SRA(ty,_,_)) = ty
     | size(T.SRL(ty,_,_)) = ty
     | size(T.SLL(ty,_,_)) = ty
     | size(T.COND(ty,_,_,_)) = ty
     | size(T.LOAD(ty,_,_)) = ty
     | size(T.CVTI2I(ty,_,_,_)) = ty
     | size(T.CVTF2I(ty,_,_,_)) = ty
     | size(T.LET(_,e)) = size e
     | size(T.PRED(e,_)) = size e
     | size(T.REXT(ty,_)) = ty
     | size(T.MARK(e,_)) = size e

   fun fsize(T.FREG(ty,_)) = ty
     | fsize(T.FLOAD(ty,_,_)) = ty
     | fsize(T.FADD(ty,_,_)) = ty
     | fsize(T.FSUB(ty,_,_)) = ty
     | fsize(T.FMUL(ty,_,_)) = ty
     | fsize(T.FDIV(ty,_,_)) = ty
     | fsize(T.FABS(ty,_)) = ty
     | fsize(T.FNEG(ty,_)) = ty
     | fsize(T.FSQRT(ty,_)) = ty
     | fsize(T.FCOND(ty,_,_,_)) = ty
     | fsize(T.CVTI2F(ty,_,_)) = ty
     | fsize(T.CVTF2F(ty,_,_)) = ty
     | fsize(T.FCOPYSIGN(ty,_,_)) = ty
     | fsize(T.FPRED(e,_)) = fsize e
     | fsize(T.FEXT(ty,_)) = ty
     | fsize(T.FMARK(e,_)) = fsize e

   fun condOf(T.CC(cc,_)) = cc
     | condOf(T.CMP(_,cc,_,_)) = cc
     | condOf(T.CCMARK(cc,_)) = condOf cc
     | condOf _ = error "condOf"

   fun fcondOf(T.FCC(fcc,_)) = fcc
     | fcondOf(T.FCMP(_,fcc,_,_)) = fcc
     | fcondOf(T.CCMARK(cc,_)) = fcondOf cc
     | fcondOf _ = error "fcondOf"

   val W = intTy

   (* To compute f.ty(a,b) 
    *
    * let r1 <- a << (intTy - ty)
    *     r2 <- b << (intTy - ty)
    *     r3 <- f(a,b) 
    * in  r3 ~>> (intTy - ty) end
    * 
    * Lal showed me this neat trick!
    *)
   fun arith(rightShift,f,ty,a,b) = 
       let val shift = T.LI(W-ty)
       in  rightShift(W,f(W,T.SLL(W,a,shift),T.SLL(W,b,shift)),shift)
       end

   fun promoteTy(e,ty) =
   let fun loop([]) = 
           raise Unsupported("can't promote integer width "^Int.toString ty)
         | loop(t::ts) = if t > ty then t else loop ts
   in  loop(naturalWidths) end

   fun promotable rightShift (e, f, ty, a, b) =
       case naturalWidths of 
         [] => arith(rightShift,f,ty,a,b) 
       | _  => f(promoteTy(e, ty), a, b)

   (*
    * Translate integer expressions of unknown types into the appropriate
    * term.
    *)

   fun compileRexp(exp) =
       case exp of
         T.CONST c => T.LABEL(T.LabelExp.CONST c)

         (* non overflow trapping ops *)
       | T.NEG(ty,a)    => T.SUB(ty,T.LI 0,a)
       | T.ADD(ty,a,b)  => promotable T.SRA (exp,T.ADD,ty,a,b)
       | T.SUB(ty,a,b)  => promotable T.SRA (exp,T.SUB,ty,a,b)
       | T.MULS(ty,a,b) => promotable T.SRA (exp,T.MULS,ty,a,b)
       | T.DIVS(ty,a,b) => promotable T.SRA (exp,T.DIVS,ty,a,b)
       | T.REMS(ty,a,b) => promotable T.SRA (exp,T.REMS,ty,a,b)
       | T.MULU(ty,a,b) => promotable T.SRL (exp,T.MULU,ty,a,b)
       | T.DIVU(ty,a,b) => promotable T.SRL (exp,T.DIVU,ty,a,b)
       | T.REMU(ty,a,b) => promotable T.SRL (exp,T.REMU,ty,a,b)

         (* for overflow trapping ops; we have to do the simulation *)
       | T.NEGT(ty,a)   => T.SUBT(ty,T.LI 0,a)
       | T.ADDT(ty,a,b) => arith (T.SRA,T.ADDT,ty,a,b)
       | T.SUBT(ty,a,b) => arith (T.SRA,T.SUBT,ty,a,b)
       | T.MULT(ty,a,b) => arith (T.SRA,T.MULT,ty,a,b)
       | T.DIVT(ty,a,b) => arith (T.SRA,T.DIVT,ty,a,b)
       | T.REMT(ty,a,b) => arith (T.SRA,T.REMT,ty,a,b)

         (* conditional evaluation rules *)
       | T.COND(ty,T.CC(cond,r),x,y) =>
           T.COND(ty,T.CMP(ty,cond,T.REG(ty,r),T.LI 0),x,y)
       | T.COND(ty,T.CCMARK(cc,a),x,y) => T.MARK(T.COND(ty,cc,x,y),a)
       | T.COND(ty,T.CMP(t,cc,e1,e2),x as (T.LI 0 | T.LI32 0w0),y) => 
           T.COND(ty,T.CMP(t,T.Basis.negateCond cc,e1,e2),y,T.LI 0)
           (* we'll let others strength reduce the multiply *)
       | T.COND(ty,cc,e1,(T.LI 0 | T.LI32 0w0)) => 
           T.MULU(ty,T.COND(ty,cc,T.LI 1,T.LI 0),e1)
       | T.COND(ty,cc,T.LI m,T.LI n) =>
           T.ADD(ty,T.MULU(ty,T.COND(ty,cc,T.LI 1,T.LI 0),T.LI(m-n)),T.LI n)
       | T.COND(ty,cc,e1,e2) =>  
           T.ADD(ty,T.MULU(ty,T.COND(ty,cc,T.LI 1,T.LI 0),T.SUB(ty,e1,e2)),e2)

       (* ones-complement.
        * WARNING: we are assuming two's complement architectures here.
        * Are there any architectures in use nowadays that doesn't use 
        * two's complement for integer arithmetic?
        *)
       | T.NOTB(ty,e) => T.XORB(ty,e,T.LI ~1)

       (* 
        * Default ways of converting integers to integers
        *)
       | T.CVTI2I(ty,T.SIGN_EXTEND,fromTy,e) => 
         if fromTy = ty then e
         else if rep = SE andalso fromTy < ty andalso 
              fromTy >= hd naturalWidths then e 
         else
             let val shift = T.LI(W - fromTy)
             in  T.SRA(W,T.SLL(W,e,shift),shift) 
             end 
       | T.CVTI2I(ty,T.ZERO_EXTEND,fromTy,e) => 
         if fromTy <= ty then e else 
            (case ty of (* ty < fromTy *)
                8  => T.ANDB(ty,e,T.LI32 0wxff) 
              | 16 => T.ANDB(ty,e,T.LI32 0wxffff) 
              | 32 => T.ANDB(ty,e,T.LI32 0wxffffffff) 
              | 64 => e
              | _  => raise Unsupported("unknown expression")
            )

       (* 
        * Converting floating point to integers.
        * The following rule handles the case when ty is not
        * one of the naturally supported widths on the machine.
        *)
       | T.CVTF2I(ty,round,fty,e) => 
         let val ty' = promoteTy(exp,ty)
         in  T.CVTI2I(ty,T.SIGN_EXTEND,ty',T.CVTF2I(ty',round,fty,e))
         end

       | exp => raise Unsupported("unknown expression")

   fun compileFexp fexp = raise Unsupported("unknown expression")

   fun mark(s,[]) = s
     | mark(s,a::an) = mark(T.ANNOTATION(s,a),an)

   fun compileStm (T.SEQ s) = s
     | compileStm (T.IF(ctrl,cond,T.JMP(_,T.LABEL(LE.LABEL L),_),T.SEQ [])) = 
           [T.BCC(ctrl,cond,L)]
     | compileStm (T.IF(ctrl,cond,yes,no)) = 
       let val L1 = Label.newLabel ""
           val L2 = Label.newLabel ""
       in  [T.BCC(ctrl,cond,L1),
            no,
            T.JMP([],T.LABEL(LE.LABEL L2),[]),
            T.DEFINE L1,
            yes,
            T.DEFINE L2
           ]
       end
     | compileStm stm = error "compileStm"

   (*
    * This function translations conditional expressions into a 
    * branch sequence.  
    * Note: we'll actually take advantage of the fact that 
    * e1 and e2 are allowed to be eagerly evaluated. 
    *)
   fun compileCond{exp=(ty,ccexp,e1,e2),rd,an} =
   let val L1 = Label.newLabel ""
   in  [T.MV(ty,rd,e1),
        mark(T.BCC([],ccexp,L1),an),
        T.MV(ty,rd,e2),
        T.DEFINE L1
       ]
   end
   fun compileFcond{exp=(fty,ccexp,e1,e2),fd,an} =
   let val L1 = Label.newLabel ""
   in  [T.FMV(fty,fd,e1),
        mark(T.BCC([],ccexp,L1),an),
        T.FMV(fty,fd,e2),
        T.DEFINE L1
       ]
   end
 
end