(*Generated by Lem from ast.lem.*)
open HolKernel Parse boolLib bossLib;
open pervasives_extraTheory;

val _ = numLib.prefer_num();



val _ = new_theory "ast"

(*open import Pervasives_extra*)

(* Literal constants *)
val _ = Hol_datatype `
 lit =
    IntLit of int
  | Bool of bool
  | Unit`;


(* Built-in binary operations (including function application) *)

val _ = Hol_datatype `
 opn = Plus | Minus | Times | Divide | Modulo`;

val _ = Hol_datatype `
 opb = Lt | Gt | Leq | Geq`;


val _ = Define `
 (opn_lookup dict_Num_NumAdd_a dict_Num_NumDivision_a dict_Num_NumMinus_a dict_Num_NumMult_a dict_Num_NumRemainder_a n = ((case n of
    Plus => dict_Num_NumAdd_a.numAdd_method
  | Minus => dict_Num_NumMinus_a.numMinus_method
  | Times => dict_Num_NumMult_a.numMult_method
  | Divide => dict_Num_NumDivision_a.numDivision_method
  | Modulo => dict_Num_NumRemainder_a.mod_method
)))`;


val _ = Define `
 (opb_lookup n : int -> int -> bool = ((case n of
    Lt => (<)
  | Gt => (>)
  | Leq => (<=)
  | Geq => (>=)
)))`;


(* Opapp is function application *)
val _ = Hol_datatype `
 op =
    Opn of opn
  | Opb of opb
  | Equality
  | Opapp
  | Opassign`;


val _ = Hol_datatype `
 uop =
    Opref
  | Opderef`;


(* Built-in logical operations *)
val _ = Hol_datatype `
 lop =
    And
  | Or`;


(* Module names *)
val _ = type_abbrev( "modN" , ``: string``);

(* Identifiers *)
val _ = Hol_datatype `
 id =
    Short of 'a
  | Long of modN => 'a`;


val _ = Define `
(instance_Basic_classes_Eq_Ast_id_dict dict_Basic_classes_Eq_a =(<|

  isEqual_method :=(\ x y. (case (x,y) of
        (Short a, Short b) => a = b
      | (Long mn a, Long mn' b) => (mn = mn') /\ (a = b)
    ))|>))`;


(* Variable names *)
val _ = type_abbrev( "varN" , ``: string``);

(* Constructor names (from datatype definitions) *)
val _ = type_abbrev( "conN" , ``: string``);

(* Type names *)
val _ = type_abbrev( "typeN" , ``: string``);

(* Type variable names *)
val _ = type_abbrev( "tvarN" , ``: string``);

(*val mk_id : forall 'a. maybe modN -> 'a -> id 'a*)
val _ = Define `
 (mk_id mn_opt n =  
((case mn_opt of
      (NONE) => Short n
    | (SOME mn) => Long mn n
  )))`;


(* Types
 * 0-ary type applications represent unparameterised types (e.g., num or string)
 *)
val _ = Hol_datatype `
 tc0 = 
    TC_name of typeN id
  | TC_int
  | TC_bool
  | TC_unit
  | TC_ref
  | TC_fn
  | TC_tup
  | TC_exn`;


val _ = Hol_datatype `
 t =
    Tvar of tvarN
  (* DeBruin indexed type variables. *)
  | Tvar_db of num
  | Tapp of t list => tc0`;


val _ = Define `
 (Tint = (Tapp [] TC_int))`;

val _ = Define `
 (Tunit = (Tapp [] TC_unit))`;

val _ = Define `
 (Tbool = (Tapp [] TC_bool))`;

val _ = Define `
 (Tref t = (Tapp [t] TC_ref))`;

val _ = Define `
 (Tfn t1 t2 = (Tapp [t1;t2] TC_fn))`;

val _ = Define `
 (Texn = (Tapp [] TC_exn))`;


(* Patterns *)
val _ = Hol_datatype `
 pat =
    Pvar of varN
  | Plit of lit
  (* Constructor applications. *)
  | Pcon of  ( conN id)option => pat list
  | Pref of pat`;


(* Expressions *)
val _ = Hol_datatype `
 exp =
    Raise of exp
  | Handle of exp => (pat # exp) list
  | Lit of lit
  (* Constructor application. *)
  | Con of  ( conN id)option => exp list
  | Var of varN id
  | Fun of varN => exp
  (* Application of a unary operator *)
  | Uapp of uop => exp
  (* Application of an operator (including function application) *)
  | App of op => exp => exp
  (* Logical operations (and, or) *)
  | Log of lop => exp => exp
  | If of exp => exp => exp
  (* Pattern matching *)
  | Mat of exp => (pat # exp) list
  (* The number is how many type variables are bound. *)
  | Let of varN => exp => exp
  (* Local definition of (potentially) mutually recursive functions
   * The first varN is the function's name, and the second varN is its
   * parameter. *)
  | Letrec of (varN # varN # exp) list => exp`;


val _ = type_abbrev( "type_def" , ``: ( tvarN list # typeN # (conN # t list) list) list``);

(* Declarations *)
val _ = Hol_datatype `
 dec =
  (* Top-level bindings
   * The number is how many type variables are bound.
   * The pattern allows several names to be bound at once *)
    Dlet of pat => exp
  (* Mutually recursive function definition *)
  | Dletrec of (varN # varN # exp) list
  (* Type definition
     Defines several types, each of which has several named variants, which can
     in turn have several arguments *)
  | Dtype of type_def
  | Dexn of conN => t list`;


val _ = type_abbrev( "decs" , ``: dec list``); 

val _ = Hol_datatype `
 spec =
    Sval of varN => t
  | Stype of type_def
  | Stype_opq of tvarN list => typeN
  | Sexn of conN => t list`;


val _ = type_abbrev( "specs" , ``: spec list``);

val _ = Hol_datatype `
 top =
    Tmod of modN =>  specs option => decs
  | Tdec of dec`;


val _ = type_abbrev( "prog" , ``: top list``);

(* Accumulates the bindings of a pattern *)
(*val pat_bindings : pat -> list varN -> list varN*)
 val pat_bindings_defn = Hol_defn "pat_bindings" `

(pat_bindings (Pvar n) already_bound =  
(n::already_bound))
/\
(pat_bindings (Plit l) already_bound =
  already_bound)
/\
(pat_bindings (Pcon _ ps) already_bound =  
(pats_bindings ps already_bound))
/\
(pat_bindings (Pref p) already_bound =  
(pat_bindings p already_bound))
/\
(pats_bindings [] already_bound =
  already_bound)
/\
(pats_bindings (p::ps) already_bound =  
(pats_bindings ps (pat_bindings p already_bound)))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) Defn.save_defn pat_bindings_defn;
val _ = export_theory()

