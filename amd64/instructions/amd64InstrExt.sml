(* amd64InstrExt.sml
 *
 * COPYRIGHT (c) 2007 The Fellowship of SML/NJ (http://smlnj.org)
 *
 * emit code for extensions to the amd64 instruction set.
 *)

structure AMD64InstrExt =
  struct

    datatype fsz = SINGLE | DOUBLE

    datatype ('s, 'r, 'f, 'c) sext 
	= PUSHQ of 'r
 	| POP of 'r 
        | LEAVE
        | RET of 'r
    (* atomic compare and exchange instructions.
     *   CMPXCHG(src, dst)	compares dst with %eax (or %rax) register.
     *				if they are equal, then the ZF flag is set and
     *				src is stored in dst; otherwise dst is loaded
     *				into %eax (or %rax) and ZF is cleared.
     *)
        | LOCK_CMPXCHGL of ('r * 'r)	(* 32-bit compare and exchange *)
        | LOCK_CMPXCHGQ of ('r * 'r)	(* 64-bit compare and exchange *)

  end (* AMD64InstrExt *)