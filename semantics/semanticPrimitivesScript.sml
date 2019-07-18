(*Generated by Lem from semanticPrimitives.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_pervasivesTheory libTheory lem_list_extraTheory lem_stringTheory lem_string_extraTheory astTheory namespaceTheory ffiTheory fpSemTheory;

val _ = numLib.prefer_num();



val _ = new_theory "semanticPrimitives"

(*
  Definitions of semantic primitives (e.g., values, and functions for doing
  primitive operations) used in the semantics.
*)
(*open import Pervasives*)
(*open import Lib*)
(*import List_extra*)
(*import String*)
(*import String_extra*)
(*open import Ast*)
(*open import Namespace*)
(*open import Ffi*)
(*open import FpSem*)

(* Constructors and exceptions need unique identities, which we represent by stamps. *)
val _ = Hol_datatype `
 stamp =
  (* Each type gets a unique number, and the constructor name must be unique
     inside of the type *)
    TypeStamp of conN => num
  | ExnStamp of num`;


(*
val type_defs_to_new_tdecs : list modN -> type_def -> set tid_or_exn
let type_defs_to_new_tdecs mn tdefs =
  Set.fromList (List.map (fun (tvs,tn,ctors) -> TypeId (mk_id mn tn)) tdefs)
*)

val _ = Hol_datatype `
(*  'v *) sem_env =
  <| v : (modN, varN, 'v) namespace
   (* Lexical mapping of constructor idents to arity, stamp pairs *)
   ; c : (modN, conN, (num # stamp)) namespace
   |>`;


(* Value forms *)
val _ = Hol_datatype `
 v =
    Litv of lit
  (* Constructor application. Can be a tuple or a given constructor of a given type *)
  | Conv of  stamp option => v list
  (* Function closures
     The environment is used for the free variables in the function *)
  | Closure of v sem_env => varN => exp
  (* Function closure for recursive functions
   * See Closure and Letrec above
   * The last variable name indicates which function from the mutually
   * recursive bundle this closure value represents *)
  | Recclosure of v sem_env => (varN # varN # exp) list => varN
  | Loc of num
  | Vectorv of v list`;


val _ = type_abbrev( "env_ctor" , ``: (modN, conN, (num # stamp)) namespace``);
val _ = type_abbrev( "env_val" , ``: (modN, varN, v) namespace``);

val _ = Define `
 ((bind_stamp:stamp)=  (ExnStamp(( 0 : num))))`;

val _ = Define `
 ((chr_stamp:stamp)=  (ExnStamp(( 1 : num))))`;

val _ = Define `
 ((div_stamp:stamp)=  (ExnStamp(( 2 : num))))`;

val _ = Define `
 ((subscript_stamp:stamp)=  (ExnStamp(( 3 : num))))`;


val _ = Define `
 ((bind_exn_v:v)=  (Conv (SOME bind_stamp) []))`;

val _ = Define `
 ((chr_exn_v:v)=  (Conv (SOME chr_stamp) []))`;

val _ = Define `
 ((div_exn_v:v)=  (Conv (SOME div_stamp) []))`;

val _ = Define `
 ((sub_exn_v:v)=  (Conv (SOME subscript_stamp) []))`;


val _ = Define `
 ((bool_type_num:num) : num= (( 0 : num)))`;

val _ = Define `
 ((list_type_num:num) : num= (( 1 : num)))`;


(* The result of evaluation *)
val _ = Hol_datatype `
 abort =
    Rtype_error
  | Rtimeout_error
  | Rffi_error of final_event`;


val _ = Hol_datatype `
 error_result =
    Rraise of 'a (* Should only be a value of type exn *)
  | Rabort of abort`;


val _ = Hol_datatype `
 result =
    Rval of 'a
  | Rerr of 'b error_result`;


(* Stores *)
val _ = Hol_datatype `
 store_v =
  (* A ref cell *)
    Refv of 'a
  (* A byte array *)
  | W8array of word8 list
  (* An array of values *)
  | Varray of 'a list`;


(*val store_v_same_type : forall 'a. store_v 'a -> store_v 'a -> bool*)
val _ = Define `
 ((store_v_same_type:'a store_v -> 'a store_v -> bool) v1 v2=
   ((case (v1,v2) of
    (Refv _, Refv _) => T
  | (W8array _,W8array _) => T
  | (Varray _,Varray _) => T
  | _ => F
  )))`;


(* The nth item in the list is the value at location n *)
val _ = type_abbrev((*  'a *) "store" , ``: ( 'a store_v) list``);

(*val empty_store : forall 'a. store 'a*)
val _ = Define `
 ((empty_store:('a store_v)list)=  ([]))`;


(*val store_lookup : forall 'a. nat -> store 'a -> maybe (store_v 'a)*)
val _ = Define `
 ((store_lookup:num ->('a store_v)list ->('a store_v)option) l st=
   (if l < LENGTH st then
    SOME (EL l st)
  else
    NONE))`;


(*val store_alloc : forall 'a. store_v 'a -> store 'a -> store 'a * nat*)
val _ = Define `
 ((store_alloc:'a store_v ->('a store_v)list ->('a store_v)list#num) v st=
   ((st ++ [v]), LENGTH st))`;


(*val store_assign : forall 'a. nat -> store_v 'a -> store 'a -> maybe (store 'a)*)
val _ = Define `
 ((store_assign:num -> 'a store_v ->('a store_v)list ->(('a store_v)list)option) n v st=
   (if (n < LENGTH st) /\
     store_v_same_type (EL n st) v
  then
    SOME (LUPDATE v n st)
  else
    NONE))`;


val _ = Hol_datatype `
(*  'ffi *) state =
  <| clock : num
   ; refs  : v store
   ; ffi : 'ffi ffi_state
   ; next_type_stamp : num
   ; next_exn_stamp : num
   |>`;


(* Other primitives *)
(* Check that a constructor is properly applied *)
(*val do_con_check : env_ctor -> maybe (id modN conN) -> nat -> bool*)
val _ = Define `
 ((do_con_check:((string),(string),(num#stamp))namespace ->(((string),(string))id)option -> num -> bool) cenv n_opt l=
   ((case n_opt of
      NONE => T
    | SOME n =>
        (case nsLookup cenv n of
            NONE => F
          | SOME (l',_) => l = l'
        )
  )))`;


(*val build_conv : env_ctor -> maybe (id modN conN) -> list v -> maybe v*)
val _ = Define `
 ((build_conv:((string),(string),(num#stamp))namespace ->(((string),(string))id)option ->(v)list ->(v)option) envC cn vs=
   ((case cn of
      NONE =>
        SOME (Conv NONE vs)
    | SOME id =>
        (case nsLookup envC id of
            NONE => NONE
          | SOME (len,stamp) => SOME (Conv (SOME stamp) vs)
        )
  )))`;


(*val lit_same_type : lit -> lit -> bool*)
val _ = Define `
 ((lit_same_type:lit -> lit -> bool) l1 l2=
   ((case (l1,l2) of
      (IntLit _, IntLit _) => T
    | (Char _, Char _) => T
    | (StrLit _, StrLit _) => T
    | (Word8 _, Word8 _) => T
    | (Word64 _, Word64 _) => T
    | _ => F
  )))`;


val _ = Hol_datatype `
 match_result =
    No_match
  | Match_type_error
  | Match of 'a`;


(*val same_type : stamp -> stamp -> bool*)
 val _ = Define `
 ((same_type:stamp -> stamp -> bool) (TypeStamp _ n1) (TypeStamp _ n2)=  (n1 = n2))
/\ ((same_type:stamp -> stamp -> bool) (ExnStamp _) (ExnStamp _)=  T)
/\ ((same_type:stamp -> stamp -> bool) _ _=  F)`;


(*val same_ctor : stamp -> stamp -> bool*)
val _ = Define `
 ((same_ctor:stamp -> stamp -> bool) stamp1 stamp2=  (stamp1 = stamp2))`;


(*val ctor_same_type : maybe stamp -> maybe stamp -> bool*)
val _ = Define `
 ((ctor_same_type:(stamp)option ->(stamp)option -> bool) c1 c2=
   ((case (c1,c2) of
      (NONE, NONE) => T
    | (SOME stamp1, SOME stamp2) => same_type stamp1 stamp2
    | _ => F
  )))`;


(* A big-step pattern matcher.  If the value matches the pattern, return an
 * environment with the pattern variables bound to the corresponding sub-terms
 * of the value; this environment extends the environment given as an argument.
 * No_match is returned when there is no match, but any constructors
 * encountered in determining the match failure are applied to the correct
 * number of arguments, and constructors in corresponding positions in the
 * pattern and value come from the same type.  Match_type_error is returned
 * when one of these conditions is violated *)
(*val pmatch : env_ctor -> store v -> pat -> v -> alist varN v -> match_result (alist varN v)*)
 val pmatch_defn = Defn.Hol_multi_defns `

((pmatch:((string),(string),(num#stamp))namespace ->((v)store_v)list -> pat -> v ->(string#v)list ->((string#v)list)match_result) envC s Pany v' env=  (Match env))
/\
((pmatch:((string),(string),(num#stamp))namespace ->((v)store_v)list -> pat -> v ->(string#v)list ->((string#v)list)match_result) envC s (Pvar x) v' env=  (Match ((x,v')::env)))
/\
((pmatch:((string),(string),(num#stamp))namespace ->((v)store_v)list -> pat -> v ->(string#v)list ->((string#v)list)match_result) envC s (Plit l) (Litv l') env=
   (if l = l' then
    Match env
  else if lit_same_type l l' then
    No_match
  else
    Match_type_error))
/\
((pmatch:((string),(string),(num#stamp))namespace ->((v)store_v)list -> pat -> v ->(string#v)list ->((string#v)list)match_result) envC s (Pcon (SOME n) ps) (Conv (SOME stamp') vs) env=
   ((case nsLookup envC n of
      SOME (l,stamp) =>
        if same_type stamp stamp' /\ (LENGTH ps = l) then
          if same_ctor stamp stamp' then
            if LENGTH vs = l then
              pmatch_list envC s ps vs env
            else
              Match_type_error
          else
            No_match
        else
          Match_type_error
    | _ => Match_type_error
  )))
/\
((pmatch:((string),(string),(num#stamp))namespace ->((v)store_v)list -> pat -> v ->(string#v)list ->((string#v)list)match_result) envC s (Pcon NONE ps) (Conv NONE vs) env=
   (if LENGTH ps = LENGTH vs then
    pmatch_list envC s ps vs env
  else
    Match_type_error))
/\
((pmatch:((string),(string),(num#stamp))namespace ->((v)store_v)list -> pat -> v ->(string#v)list ->((string#v)list)match_result) envC s (Pref p) (Loc lnum) env=
   ((case store_lookup lnum s of
      SOME (Refv v) => pmatch envC s p v env
    | SOME _ => Match_type_error
    | NONE => Match_type_error
  )))
/\
((pmatch:((string),(string),(num#stamp))namespace ->((v)store_v)list -> pat -> v ->(string#v)list ->((string#v)list)match_result) envC s (Ptannot p t) v env=
   (pmatch envC s p v env))
/\
((pmatch:((string),(string),(num#stamp))namespace ->((v)store_v)list -> pat -> v ->(string#v)list ->((string#v)list)match_result) envC _ _ _ env=  Match_type_error)
/\
((pmatch_list:((string),(string),(num#stamp))namespace ->((v)store_v)list ->(pat)list ->(v)list ->(string#v)list ->((string#v)list)match_result) envC s [] [] env=  (Match env))
/\
((pmatch_list:((string),(string),(num#stamp))namespace ->((v)store_v)list ->(pat)list ->(v)list ->(string#v)list ->((string#v)list)match_result) envC s (p::ps) (v::vs) env=
   ((case pmatch envC s p v env of
      No_match => No_match
    | Match_type_error => Match_type_error
    | Match env' => pmatch_list envC s ps vs env'
  )))
/\
((pmatch_list:((string),(string),(num#stamp))namespace ->((v)store_v)list ->(pat)list ->(v)list ->(string#v)list ->((string#v)list)match_result) envC s _ _ env=  Match_type_error)`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) pmatch_defn;

(* Bind each function of a mutually recursive set of functions to its closure *)
(*val build_rec_env : list (varN * varN * exp) -> sem_env v -> env_val -> env_val*)
val _ = Define `
 ((build_rec_env:(varN#varN#exp)list ->(v)sem_env ->((string),(string),(v))namespace ->((string),(string),(v))namespace) funs cl_env add_to_env=
   (FOLDR
    (\ (f,x,e) env' .  nsBind f (Recclosure cl_env funs f) env')
    add_to_env
    funs))`;


(* Lookup in the list of mutually recursive functions *)
(*val find_recfun : forall 'a 'b. varN -> list (varN * 'a * 'b) -> maybe ('a * 'b)*)
 val _ = Define `
 ((find_recfun:string ->(string#'a#'b)list ->('a#'b)option) n funs=
   ((case funs of
      [] => NONE
    | (f,x,e) :: funs =>
        if f = n then
          SOME (x,e)
        else
          find_recfun n funs
  )))`;


val _ = Hol_datatype `
 eq_result =
    Eq_val of bool
  | Eq_type_error`;


(*val do_eq : v -> v -> eq_result*)
 val do_eq_defn = Defn.Hol_multi_defns `

((do_eq:v -> v -> eq_result) (Litv l1) (Litv l2)=
   (if lit_same_type l1 l2 then Eq_val (l1 = l2)
  else Eq_type_error))
/\
((do_eq:v -> v -> eq_result) (Loc l1) (Loc l2)=  (Eq_val (l1 = l2)))
/\
((do_eq:v -> v -> eq_result) (Conv cn1 vs1) (Conv cn2 vs2)=
   (if (cn1 = cn2) /\ (LENGTH vs1 = LENGTH vs2) then
    do_eq_list vs1 vs2
  else if ctor_same_type cn1 cn2 then
    Eq_val F
  else
    Eq_type_error))
/\
((do_eq:v -> v -> eq_result) (Vectorv vs1) (Vectorv vs2)=
   (if LENGTH vs1 = LENGTH vs2 then
    do_eq_list vs1 vs2
  else
    Eq_val F))
/\
((do_eq:v -> v -> eq_result) (Closure _ _ _) (Closure _ _ _)=  (Eq_val T))
/\
((do_eq:v -> v -> eq_result) (Closure _ _ _) (Recclosure _ _ _)=  (Eq_val T))
/\
((do_eq:v -> v -> eq_result) (Recclosure _ _ _) (Closure _ _ _)=  (Eq_val T))
/\
((do_eq:v -> v -> eq_result) (Recclosure _ _ _) (Recclosure _ _ _)=  (Eq_val T))
/\
((do_eq:v -> v -> eq_result) _ _=  Eq_type_error)
/\
((do_eq_list:(v)list ->(v)list -> eq_result) [] []=  (Eq_val T))
/\
((do_eq_list:(v)list ->(v)list -> eq_result) (v1::vs1) (v2::vs2)=
   ((case do_eq v1 v2 of
      Eq_type_error => Eq_type_error
    | Eq_val r =>
        if ~ r then
          Eq_val F
        else
          do_eq_list vs1 vs2
  )))
/\
((do_eq_list:(v)list ->(v)list -> eq_result) _ _=  (Eq_val F))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) do_eq_defn;

(* Do an application *)
(*val do_opapp : list v -> maybe (sem_env v * exp)*)
val _ = Define `
 ((do_opapp:(v)list ->((v)sem_env#exp)option) vs=
   ((case vs of
    [Closure env n e; v] =>
      SOME (( env with<| v := (nsBind n v env.v) |>), e)
  | [Recclosure env funs n; v] =>
      if ALL_DISTINCT (MAP (\ (f,x,e) .  f) funs) then
        (case find_recfun n funs of
            SOME (n,e) => SOME (( env with<| v := (nsBind n v (build_rec_env funs env env.v)) |>), e)
          | NONE => NONE
        )
      else
        NONE
  | _ => NONE
  )))`;


(* If a value represents a list, get that list. Otherwise return Nothing *)
(*val v_to_list : v -> maybe (list v)*)
 val v_to_list_defn = Defn.Hol_multi_defns `
 ((v_to_list:v ->((v)list)option) (Conv (SOME stamp) [])=
   (if stamp = TypeStamp "[]" list_type_num then
    SOME []
  else
    NONE))
/\ ((v_to_list:v ->((v)list)option) (Conv (SOME stamp) [v1;v2])=
   (if stamp = TypeStamp "::" list_type_num then
    (case v_to_list v2 of
        SOME vs => SOME (v1::vs)
      | NONE => NONE
    )
  else
    NONE))
/\ ((v_to_list:v ->((v)list)option) _=  NONE)`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) v_to_list_defn;

(*val list_to_v : list v -> v*)
 val list_to_v_defn = Defn.Hol_multi_defns `
 ((list_to_v:(v)list -> v) []=  (Conv (SOME (TypeStamp "[]" list_type_num)) []))
/\ ((list_to_v:(v)list -> v) (x::xs)=  (Conv (SOME (TypeStamp "::" list_type_num)) [x; list_to_v xs]))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) list_to_v_defn;

(*val v_to_char_list : v -> maybe (list char)*)
 val v_to_char_list_defn = Defn.Hol_multi_defns `
 ((v_to_char_list:v ->((char)list)option) (Conv (SOME stamp) [])=
   (if stamp = TypeStamp "[]" list_type_num then
    SOME []
  else
    NONE))
/\ ((v_to_char_list:v ->((char)list)option) (Conv (SOME stamp) [Litv (Char c);v])=
   (if stamp = TypeStamp "::" list_type_num then
    (case v_to_char_list v of
        SOME cs => SOME (c::cs)
      | NONE => NONE
    )
  else
    NONE))
/\ ((v_to_char_list:v ->((char)list)option) _=  NONE)`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) v_to_char_list_defn;

(*val vs_to_string : list v -> maybe string*)
 val vs_to_string_defn = Defn.Hol_multi_defns `
 ((vs_to_string:(v)list ->(string)option) []=  (SOME ""))
/\ ((vs_to_string:(v)list ->(string)option) (Litv(StrLit s1)::vs)=
   ((case vs_to_string vs of
    SOME s2 => SOME ( STRCAT s1 s2)
  | _ => NONE
  )))
/\ ((vs_to_string:(v)list ->(string)option) _=  NONE)`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) vs_to_string_defn;

(*val copy_array : forall 'a. list 'a * integer -> integer -> maybe (list 'a * integer) -> maybe (list 'a)*)
val _ = Define `
 ((copy_array:'a list#int -> int ->('a list#int)option ->('a list)option) (src,srcoff) len d=
   (if (srcoff <( 0 : int)) \/ ((len <( 0 : int)) \/ (LENGTH src < Num (ABS (I (srcoff + len))))) then NONE else
    let copied = (TAKE (Num (ABS (I len))) (DROP (Num (ABS (I srcoff))) src)) in
    (case d of
      SOME (dst,dstoff) =>
        if (dstoff <( 0 : int)) \/ (LENGTH dst < Num (ABS (I (dstoff + len)))) then NONE else
          SOME ((TAKE (Num (ABS (I dstoff))) dst ++
                copied) ++
                DROP (Num (ABS (I (dstoff + len)))) dst)
    | NONE => SOME copied
    )))`;


(*val ws_to_chars : list word8 -> list char*)
val _ = Define `
 ((ws_to_chars:(word8)list ->(char)list) ws=  (MAP (\ w .  CHR(w2n w)) ws))`;


(*val chars_to_ws : list char -> list word8*)
val _ = Define `
 ((chars_to_ws:(char)list ->(word8)list) cs=  (MAP (\ c .  i2w(int_of_num(ORD c))) cs))`;


(*val opn_lookup : opn -> integer -> integer -> integer*)
val _ = Define `
 ((opn_lookup:opn -> int -> int -> int) n : int -> int -> int=  ((case n of
    Plus => (+)
  | Minus => (-)
  | Times => ( * )
  | Divide => (/)
  | Modulo => (%)
)))`;


(*val opb_lookup : opb -> integer -> integer -> bool*)
val _ = Define `
 ((opb_lookup:opb -> int -> int -> bool) n : int -> int -> bool=  ((case n of
    Lt => (<)
  | Gt => (>)
  | Leq => (<=)
  | Geq => (>=)
)))`;


(*val opw8_lookup : opw -> word8 -> word8 -> word8*)
val _ = Define `
 ((opw8_lookup:opw -> word8 -> word8 -> word8) op=  ((case op of
    Andw => word_and
  | Orw => word_or
  | Xor => word_xor
  | Add => word_add
  | Sub => word_sub
)))`;


(*val opw64_lookup : opw -> word64 -> word64 -> word64*)
val _ = Define `
 ((opw64_lookup:opw -> word64 -> word64 -> word64) op=  ((case op of
    Andw => word_and
  | Orw => word_or
  | Xor => word_xor
  | Add => word_add
  | Sub => word_sub
)))`;


(*val shift8_lookup : shift -> word8 -> nat -> word8*)
val _ = Define `
 ((shift8_lookup:shift -> word8 -> num -> word8) sh=  ((case sh of
    Lsl => word_lsl
  | Lsr => word_lsr
  | Asr => word_asr
  | Ror => word_ror
)))`;


(*val shift64_lookup : shift -> word64 -> nat -> word64*)
val _ = Define `
 ((shift64_lookup:shift -> word64 -> num -> word64) sh=  ((case sh of
    Lsl => word_lsl
  | Lsr => word_lsr
  | Asr => word_asr
  | Ror => word_ror
)))`;


(*val Boolv : bool -> v*)
val _ = Define `
 ((Boolv:bool -> v) b=  (if b
  then Conv (SOME (TypeStamp "True" bool_type_num)) []
  else Conv (SOME (TypeStamp "False" bool_type_num)) []))`;


val _ = Hol_datatype `
 exp_or_val =
    Exp of exp
  | Val of v`;


val _ = type_abbrev((* ( 'ffi, 'v) *) "store_ffi" , ``: 'v store # 'ffi ffi_state``);

(* get_carg_sem “:α store_v list -> c_type -> v -> c_value option” *)

val _ = Define `
  (get_carg_sem _ (C_array conf) (Litv(StrLit s)) =
    if conf.mutable then
      NONE
    else
      SOME (C_arrayv(MAP (\ c .  n2w(ORD c)) (EXPLODE s))))
/\ (get_carg_sem st (C_array conf) (Loc lnum) =
     if conf.mutable then
       (case store_lookup lnum st of
         | SOME (W8array ws) => SOME(C_arrayv ws)
         | _ => NONE)
     else NONE)
/\ (get_carg_sem _ C_bool v =
     if v = Boolv T then
       SOME(C_primv(C_boolv T))
     else if v = Boolv F then
       SOME(C_primv(C_boolv F))
     else NONE)
/\ (get_carg_sem _ C_int (Litv(IntLit n)) =
     SOME(C_primv(C_intv n)))
/\ (get_carg_sem _ _ _ = NONE)`


val _ = Define
  `(get_cargs_sem s [] [] = SOME [])
/\ (get_cargs_sem s (ty::tys) (arg::args) =
     OPTION_MAP2 CONS (get_carg_sem s ty arg) (get_cargs_sem s tys args))
/\ (get_cargs_sem _ _ _ = NONE)
`


val _ = Define `
   (store_carg_sem (Loc lnum) ws s = store_assign lnum (W8array ws) s)
/\ (store_carg_sem  _ _ s = SOME s)`


val _ = Define
  `(store_cargs_sem [] [] s = SOME s)
/\ (store_cargs_sem (marg::margs) (w::ws) s =
      case store_carg_sem marg w s of
        | SOME s' => store_cargs_sem margs ws s'
	| NONE => NONE )
/\ (store_cargs_sem _ _ s = SOME s)
  `

val _ = Define `
  als_args cts args =
  (MAP
    (MAP FST o λ(ct,v).
      FILTER
          (λ(n',ct',v'). v = v')
          (MAPi $,
            (FILTER (is_mutty o FST) (ZIP (cts,args))))
    )
    (FILTER (is_mutty o FST) (ZIP (cts,args)))
  )
`

val _ = Define
`(get_ret_val (SOME(C_boolv b)) = Boolv b)
/\ (get_ret_val (SOME(C_intv i)) = Litv(IntLit i))
/\ (get_ret_val _ = Conv NONE [])
  `

val _ = Define
`get_mut_args cts cargs = MAP SND (FILTER (is_mutty o FST) (ZIP(cts,cargs)))
`


val _ = Define
  `do_ffi s t n args =
   case FIND (λx. x.mlname = n) (debug_sig::t.signatures) of
     SOME sign =>
       (case get_cargs_sem s sign.args args of
        | SOME cargs =>
          (case call_FFI t n sign cargs (als_args sign.args args) of
	   | SOME (FFI_return t' newargs retv) =>
              (case store_cargs_sem (get_mut_args sign.args args) newargs s of 
		| SOME s' => SOME ((s', t'), Rval (get_ret_val retv))
	        | NONE => NONE) 
	   | SOME (FFI_final outcome) => SOME ((s, t), Rerr (Rabort (Rffi_error outcome)))
           | NONE => NONE)
        | NONE => NONE)
    | NONE => NONE
  `

val _ = Define `
 ((do_app:((v)store_v)list#'ffi ffi_state -> op ->(v)list ->((((v)store_v)list#'ffi ffi_state)#((v),(v))result)option) ((s: v store),(t: 'ffi ffi_state)) op vs=
   ((case (op, vs) of
      (ListAppend, [x1; x2]) =>
      (case (v_to_list x1, v_to_list x2) of
          (SOME xs, SOME ys) => SOME ((s,t), Rval (list_to_v (xs ++ ys)))
        | _ => NONE
      )
    | (Opn op, [Litv (IntLit n1); Litv (IntLit n2)]) =>
        if ((op = Divide) \/ (op = Modulo)) /\ (n2 =( 0 : int)) then
          SOME ((s,t), Rerr (Rraise div_exn_v))
        else
          SOME ((s,t), Rval (Litv (IntLit (opn_lookup op n1 n2))))
    | (Opb op, [Litv (IntLit n1); Litv (IntLit n2)]) =>
        SOME ((s,t), Rval (Boolv (opb_lookup op n1 n2)))
    | (Opw W8 op, [Litv (Word8 w1); Litv (Word8 w2)]) =>
        SOME ((s,t), Rval (Litv (Word8 (opw8_lookup op w1 w2))))
    | (Opw W64 op, [Litv (Word64 w1); Litv (Word64 w2)]) =>
        SOME ((s,t), Rval (Litv (Word64 (opw64_lookup op w1 w2))))
    | (FP_top top, [Litv (Word64 w1); Litv (Word64 w2); Litv (Word64 w3)]) =>
        SOME ((s,t), Rval (Litv (Word64 (fp_top top w1 w2 w3))))
    | (FP_bop bop, [Litv (Word64 w1); Litv (Word64 w2)]) =>
        SOME ((s,t),Rval (Litv (Word64 (fp_bop bop w1 w2))))
    | (FP_uop uop, [Litv (Word64 w)]) =>
        SOME ((s,t),Rval (Litv (Word64 (fp_uop uop w))))
    | (FP_cmp cmp, [Litv (Word64 w1); Litv (Word64 w2)]) =>
        SOME ((s,t),Rval (Boolv (fp_cmp cmp w1 w2)))
    | (Shift W8 op n, [Litv (Word8 w)]) =>
        SOME ((s,t), Rval (Litv (Word8 (shift8_lookup op w n))))
    | (Shift W64 op n, [Litv (Word64 w)]) =>
        SOME ((s,t), Rval (Litv (Word64 (shift64_lookup op w n))))
    | (Equality, [v1; v2]) =>
        (case do_eq v1 v2 of
            Eq_type_error => NONE
          | Eq_val b => SOME ((s,t), Rval (Boolv b))
        )
    | (Opassign, [Loc lnum; v]) =>
        (case store_assign lnum (Refv v) s of
            SOME s' => SOME ((s',t), Rval (Conv NONE []))
          | NONE => NONE
        )
    | (Opref, [v]) =>
        let (s',n) = (store_alloc (Refv v) s) in
          SOME ((s',t), Rval (Loc n))
    | (Opderef, [Loc n]) =>
        (case store_lookup n s of
            SOME (Refv v) => SOME ((s,t),Rval v)
          | _ => NONE
        )
    | (Aw8alloc, [Litv (IntLit n); Litv (Word8 w)]) =>
        if n <( 0 : int) then
          SOME ((s,t), Rerr (Rraise sub_exn_v))
        else
          let (s',lnum) =
            (store_alloc (W8array (REPLICATE (Num (ABS (I n))) w)) s)
          in
            SOME ((s',t), Rval (Loc lnum))
    | (Aw8sub, [Loc lnum; Litv (IntLit i)]) =>
        (case store_lookup lnum s of
            SOME (W8array ws) =>
              if i <( 0 : int) then
                SOME ((s,t), Rerr (Rraise sub_exn_v))
              else
                let n = (Num (ABS (I i))) in
                  if n >= LENGTH ws then
                    SOME ((s,t), Rerr (Rraise sub_exn_v))
                  else
                    SOME ((s,t), Rval (Litv (Word8 (EL n ws))))
          | _ => NONE
        )
    | (Aw8length, [Loc n]) =>
        (case store_lookup n s of
            SOME (W8array ws) =>
              SOME ((s,t),Rval (Litv(IntLit(int_of_num(LENGTH ws)))))
          | _ => NONE
         )
    | (Aw8update, [Loc lnum; Litv(IntLit i); Litv(Word8 w)]) =>
        (case store_lookup lnum s of
          SOME (W8array ws) =>
            if i <( 0 : int) then
              SOME ((s,t), Rerr (Rraise sub_exn_v))
            else
              let n = (Num (ABS (I i))) in
                if n >= LENGTH ws then
                  SOME ((s,t), Rerr (Rraise sub_exn_v))
                else
                  (case store_assign lnum (W8array (LUPDATE w n ws)) s of
                      NONE => NONE
                    | SOME s' => SOME ((s',t), Rval (Conv NONE []))
                  )
        | _ => NONE
      )
    | (WordFromInt W8, [Litv(IntLit i)]) =>
        SOME ((s,t), Rval (Litv (Word8 (i2w i))))
    | (WordFromInt W64, [Litv(IntLit i)]) =>
        SOME ((s,t), Rval (Litv (Word64 (i2w i))))
    | (WordToInt W8, [Litv (Word8 w)]) =>
        SOME ((s,t), Rval (Litv (IntLit (int_of_num(w2n w)))))
    | (WordToInt W64, [Litv (Word64 w)]) =>
        SOME ((s,t), Rval (Litv (IntLit (int_of_num(w2n w)))))
    | (CopyStrStr, [Litv(StrLit str);Litv(IntLit off);Litv(IntLit len)]) =>
        SOME ((s,t),
        (case copy_array (EXPLODE str,off) len NONE of
          NONE => Rerr (Rraise sub_exn_v)
        | SOME cs => Rval (Litv(StrLit(IMPLODE(cs))))
        ))
    | (CopyStrAw8, [Litv(StrLit str);Litv(IntLit off);Litv(IntLit len);
                    Loc dst;Litv(IntLit dstoff)]) =>
        (case store_lookup dst s of
          SOME (W8array ws) =>
            (case copy_array (EXPLODE str,off) len (SOME(ws_to_chars ws,dstoff)) of
              NONE => SOME ((s,t), Rerr (Rraise sub_exn_v))
            | SOME cs =>
              (case store_assign dst (W8array (chars_to_ws cs)) s of
                SOME s' =>  SOME ((s',t), Rval (Conv NONE []))
              | _ => NONE
              )
            )
        | _ => NONE
        )
    | (CopyAw8Str, [Loc src;Litv(IntLit off);Litv(IntLit len)]) =>
      (case store_lookup src s of
        SOME (W8array ws) =>
        SOME ((s,t),
          (case copy_array (ws,off) len NONE of
            NONE => Rerr (Rraise sub_exn_v)
          | SOME ws => Rval (Litv(StrLit(IMPLODE(ws_to_chars ws))))
          ))
      | _ => NONE
      )
    | (CopyAw8Aw8, [Loc src;Litv(IntLit off);Litv(IntLit len);
                    Loc dst;Litv(IntLit dstoff)]) =>
      (case (store_lookup src s, store_lookup dst s) of
        (SOME (W8array ws), SOME (W8array ds)) =>
          (case copy_array (ws,off) len (SOME(ds,dstoff)) of
            NONE => SOME ((s,t), Rerr (Rraise sub_exn_v))
          | SOME ws =>
              (case store_assign dst (W8array ws) s of
                SOME s' => SOME ((s',t), Rval (Conv NONE []))
              | _ => NONE
              )
          )
      | _ => NONE
      )
    | (Ord, [Litv (Char c)]) =>
          SOME ((s,t), Rval (Litv(IntLit(int_of_num(ORD c)))))
    | (Chr, [Litv (IntLit i)]) =>
        SOME ((s,t),
          (if (i <( 0 : int)) \/ (i >( 255 : int)) then
            Rerr (Rraise chr_exn_v)
          else
            Rval (Litv(Char(CHR(Num (ABS (I i))))))))
    | (Chopb op, [Litv (Char c1); Litv (Char c2)]) =>
        SOME ((s,t), Rval (Boolv (opb_lookup op (int_of_num(ORD c1)) (int_of_num(ORD c2)))))
    | (Implode, [v]) =>
          (case v_to_char_list v of
            SOME ls =>
              SOME ((s,t), Rval (Litv (StrLit (IMPLODE ls))))
          | NONE => NONE
          )
    | (Explode, [v]) =>
          (case v of
            Litv (StrLit str) =>
              SOME ((s,t), Rval (list_to_v (MAP (\ c .  Litv (Char c)) (EXPLODE str))))
          | _ => NONE
          )
    | (Strsub, [Litv (StrLit str); Litv (IntLit i)]) =>
        if i <( 0 : int) then
          SOME ((s,t), Rerr (Rraise sub_exn_v))
        else
          let n = (Num (ABS (I i))) in
            if n >= STRLEN str then
              SOME ((s,t), Rerr (Rraise sub_exn_v))
            else
              SOME ((s,t), Rval (Litv (Char (EL n (EXPLODE str)))))
    | (Strlen, [Litv (StrLit str)]) =>
        SOME ((s,t), Rval (Litv(IntLit(int_of_num(STRLEN str)))))
    | (Strcat, [v]) =>
        (case v_to_list v of
          SOME vs =>
            (case vs_to_string vs of
              SOME str =>
                SOME ((s,t), Rval (Litv(StrLit str)))
            | _ => NONE
            )
        | _ => NONE
        )
    | (VfromList, [v]) =>
          (case v_to_list v of
              SOME vs =>
                SOME ((s,t), Rval (Vectorv vs))
            | NONE => NONE
          )
    | (Vsub, [Vectorv vs; Litv (IntLit i)]) =>
        if i <( 0 : int) then
          SOME ((s,t), Rerr (Rraise sub_exn_v))
        else
          let n = (Num (ABS (I i))) in
            if n >= LENGTH vs then
              SOME ((s,t), Rerr (Rraise sub_exn_v))
            else
              SOME ((s,t), Rval (EL n vs))
    | (Vlength, [Vectorv vs]) =>
        SOME ((s,t), Rval (Litv (IntLit (int_of_num (LENGTH vs)))))
    | (Aalloc, [Litv (IntLit n); v]) =>
        if n <( 0 : int) then
          SOME ((s,t), Rerr (Rraise sub_exn_v))
        else
          let (s',lnum) =
            (store_alloc (Varray (REPLICATE (Num (ABS (I n))) v)) s)
          in
            SOME ((s',t), Rval (Loc lnum))
    | (AallocEmpty, [Conv NONE []]) =>
        let (s',lnum) = (store_alloc (Varray []) s) in
          SOME ((s',t), Rval (Loc lnum))
    | (Asub, [Loc lnum; Litv (IntLit i)]) =>
        (case store_lookup lnum s of
            SOME (Varray vs) =>
              if i <( 0 : int) then
                SOME ((s,t), Rerr (Rraise sub_exn_v))
              else
                let n = (Num (ABS (I i))) in
                  if n >= LENGTH vs then
                    SOME ((s,t), Rerr (Rraise sub_exn_v))
                  else
                    SOME ((s,t), Rval (EL n vs))
          | _ => NONE
        )
    | (Alength, [Loc n]) =>
        (case store_lookup n s of
            SOME (Varray ws) =>
              SOME ((s,t),Rval (Litv(IntLit(int_of_num(LENGTH ws)))))
          | _ => NONE
         )
    | (Aupdate, [Loc lnum; Litv (IntLit i); v]) =>
        (case store_lookup lnum s of
          SOME (Varray vs) =>
            if i <( 0 : int) then
              SOME ((s,t), Rerr (Rraise sub_exn_v))
            else
              let n = (Num (ABS (I i))) in
                if n >= LENGTH vs then
                  SOME ((s,t), Rerr (Rraise sub_exn_v))
                else
                  (case store_assign lnum (Varray (LUPDATE v n vs)) s of
                      NONE => NONE
                    | SOME s' => SOME ((s',t), Rval (Conv NONE []))
                  )
        | _ => NONE
      )
    | (ConfigGC, [Litv (IntLit i); Litv (IntLit j)]) =>
        SOME ((s,t), Rval (Conv NONE []))
    | (FFI n, args) =>
        do_ffi s t n args
    | _ => NONE
  )))`;


(* Do a logical operation *)
(*val do_log : lop -> v -> exp -> maybe exp_or_val*)
val _ = Define `
 ((do_log:lop -> v -> exp ->(exp_or_val)option) l v e=
   (if ((l = And) /\ (v = Boolv T)) \/ ((l = Or) /\ (v = Boolv F)) then
    SOME (Exp e)
  else if ((l = And) /\ (v = Boolv F)) \/ ((l = Or) /\ (v = Boolv T)) then
    SOME (Val v)
  else
    NONE))`;


(* Do an if-then-else *)
(*val do_if : v -> exp -> exp -> maybe exp*)
val _ = Define `
 ((do_if:v -> exp -> exp ->(exp)option) v e1 e2=
   (if v = (Boolv T) then
    SOME e1
  else if v = (Boolv F) then
    SOME e2
  else
    NONE))`;


(* Semantic helpers for definitions *)

val _ = Define `
 ((build_constrs:num ->(string#'a list)list ->(string#(num#stamp))list) stamp condefs=
   (MAP
    (\ (conN, ts) .
      (conN, (LENGTH ts, TypeStamp conN stamp)))
    condefs))`;


(* Build a constructor environment for the type definition tds *)
(*val build_tdefs : nat -> list (list tvarN * typeN * list (conN * list ast_t)) -> env_ctor*)
 val _ = Define `
 ((build_tdefs:num ->((tvarN)list#string#(string#(ast_t)list)list)list ->((string),(string),(num#stamp))namespace) next_stamp []=  (alist_to_ns []))
/\ ((build_tdefs:num ->((tvarN)list#string#(string#(ast_t)list)list)list ->((string),(string),(num#stamp))namespace) next_stamp ((tvs,tn,condefs)::tds)=
   (nsAppend
    (build_tdefs (next_stamp +( 1 : num)) tds)
    (alist_to_ns (REVERSE (build_constrs next_stamp condefs)))))`;


(* Checks that no constructor is defined twice in a type *)
(*val check_dup_ctors : list tvarN * typeN * list (conN * list ast_t) -> bool*)
val _ = Define `
 ((check_dup_ctors:(tvarN)list#string#(string#(ast_t)list)list -> bool) (tvs, tn, condefs)=
   (ALL_DISTINCT (let x2 =
  ([]) in  FOLDR (\(n, ts) x2 .  if T then n :: x2 else x2) x2 condefs)))`;


(*val combine_dec_result : forall 'a. sem_env v -> result (sem_env v) 'a -> result (sem_env v) 'a*)
val _ = Define `
 ((combine_dec_result:(v)sem_env ->(((v)sem_env),'a)result ->(((v)sem_env),'a)result) env r=
   ((case r of
      Rerr e => Rerr e
    | Rval env' => Rval <| v := (nsAppend env'.v env.v); c := (nsAppend env'.c env.c) |>
  )))`;


(*val extend_dec_env : sem_env v -> sem_env v -> sem_env v*)
val _ = Define `
 ((extend_dec_env:(v)sem_env ->(v)sem_env ->(v)sem_env) new_env env=
   (<| c := (nsAppend new_env.c env.c); v := (nsAppend new_env.v env.v) |>))`;


(*
val decs_to_types : list dec -> list typeN
let decs_to_types ds =
  List.concat (List.map (fun d ->
        match d with
          | Dtype locs tds -> List.map (fun (tvs,tn,ctors) -> tn) tds
          | _ -> [] end)
     ds)

val no_dup_types : list dec -> bool
let no_dup_types ds =
  List.allDistinct (decs_to_types ds)

val prog_to_mods : list top -> list (list modN)
let prog_to_mods tops =
  List.concat (List.map (fun top ->
        match top with
          | Tmod mn _ _ -> [[mn]]
          | _ -> [] end)
     tops)

val no_dup_mods : list top -> set (list modN) -> bool
let no_dup_mods tops defined_mods =
  List.allDistinct (prog_to_mods tops) &&
  disjoint (Set.fromList (prog_to_mods tops)) defined_mods

val prog_to_top_types : list top -> list typeN
let prog_to_top_types tops =
  List.concat (List.map (fun top ->
        match top with
          | Tdec d -> decs_to_types [d]
          | _ -> [] end)
     tops)

val no_dup_top_types : list top -> set tid_or_exn -> bool
let no_dup_top_types tops defined_types =
  List.allDistinct (prog_to_top_types tops) &&
  disjoint (Set.fromList (List.map (fun tn -> TypeId (Short tn)) (prog_to_top_types tops))) defined_types
  *)
val _ = export_theory()
