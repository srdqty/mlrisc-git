signature HASH_TABLE =
sig

   type ('a,'b) table

   val create : { hash : 'a -> int, 
                  ==   : 'a * 'a -> bool,
                  exn  : exn,
                  size : int 
                } -> ('a,'b) table 

   val size         : ('a,'b) table -> int
   val clear        : ('a,'b) table -> unit
   val insert       : ('a,'b) table -> 'a * 'b -> unit
   val remove       : ('a,'b) table -> 'a -> unit
   val lookup       : ('a,'b) table -> 'a -> 'b 
   val copy         : ('a,'b) table -> ('a,'b) table
   val app          : ('a * 'b -> unit) -> ('a,'b) table -> unit

end

(*
 * $Log$
 *)