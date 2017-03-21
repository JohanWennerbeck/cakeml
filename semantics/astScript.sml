(*Generated by Lem from ast.lem.*)
open HolKernel Parse boolLib bossLib;
open lem_pervasivesTheory libTheory namespaceTheory;

val _ = numLib.prefer_num();



val _ = new_theory "ast"
val _ = set_grammar_ancestry ["integer", "words", "string", "namespace", "location"];

(*open import Pervasives*)
(*open import Lib*)
(*open import Namespace*)

(* Literal constants *)
val _ = Hol_datatype `
 lit =
    IntLit of int
  | Char of char
  | StrLit of string
  | Word8 of word8
  | Word64 of word64`;


(* Built-in binary operations *)
val _ = Hol_datatype `
 opn = Plus | Minus | Times | Divide | Modulo`;

val _ = Hol_datatype `
 opb = Lt | Gt | Leq | Geq`;

val _ = Hol_datatype `
 opw = Andw | Orw | Xor | Add | Sub`;

val _ = Hol_datatype `
 shift = Lsl | Lsr | Asr`;


(* Module names *)
val _ = type_abbrev( "modN" , ``: string``);

(* Variable names *)
val _ = type_abbrev( "varN" , ``: string``);

(* Constructor names (from datatype definitions) *)
val _ = type_abbrev( "conN" , ``: string``);

(* Type names *)
val _ = type_abbrev( "typeN" , ``: string``);

(* Type variable names *)
val _ = type_abbrev( "tvarN" , ``: string``);

val _ = Hol_datatype `
 word_size = W8 | W64`;


val _ = Hol_datatype `
 op =
  (* Operations on integers *)
    Opn of opn
  | Opb of opb
  (* Operations on words *)
  | Opw of word_size => opw
  | Shift of word_size => shift => num
  | Equality
  (* Function application *)
  | Opapp
  (* Reference operations *)
  | Opassign
  | Opref
  | Opderef
  (* Word8Array operations *)
  | Aw8alloc
  | Aw8sub
  | Aw8length
  | Aw8update
  | Aw8concat
  (* Word/integer conversions *)
  | WordFromInt of word_size
  | WordToInt of word_size
  (* string/bytearray conversions *)
  | CopyStrStr
  | CopyStrAw8
  | CopyAw8Str
  | CopyAw8Aw8
  (* Char operations *)
  | Ord
  | Chr
  | Chopb of opb
  (* String operations *)
  | Implode
  | Strsub
  | Strlen
  | Strcat
  (* Vector operations *)
  | VfromList
  | Vsub
  | Vlength
  (* Array operations *)
  | Aalloc
  | Asub
  | Alength
  | Aupdate
  (* Call a given foreign function *)
  | FFI of string`;


(* Logical operations *)
val _ = Hol_datatype `
 lop =
    And
  | Or`;


(* Type constructors.
 * 0-ary type applications represent unparameterised types (e.g., num or string)
 *)
val _ = Hol_datatype `
 tctor =
  (* User defined types *)
    TC_name of (modN, typeN) id
  (* Built-in types *)
  | TC_int
  | TC_char
  | TC_string
  | TC_ref
  | TC_word8
  | TC_word64
  | TC_word8array
  | TC_fn
  | TC_tup
  | TC_exn
  | TC_vector
  | TC_array`;


(* Types *)
val _ = Hol_datatype `
 t =
  (* Type variables that the user writes down ('a, 'b, etc.) *)
    Tvar of tvarN
  (* deBruijn indexed type variables.
     The type system uses these internally. *)
  | Tvar_db of num
  | Tapp of t list => tctor`;


(* Some abbreviations *)
val _ = Define `
 (Tint=  (Tapp [] TC_int))`;

val _ = Define `
 (Tchar=  (Tapp [] TC_char))`;

val _ = Define `
 (Tstring=  (Tapp [] TC_string))`;

val _ = Define `
 (Tref t=  (Tapp [t] TC_ref))`;

 val _ = Define `
 (TC_word W8=  TC_word8)
/\     (TC_word W64=  TC_word64)`;

val _ = Define `
 (Tword wz=  (Tapp [] (TC_word wz)))`;

val _ = Define `
 (Tword8=  (Tword W8))`;

val _ = Define `
 (Tword64=  (Tword W64))`;

val _ = Define `
 (Tword8array=  (Tapp [] TC_word8array))`;

val _ = Define `
 (Tfn t1 t2=  (Tapp [t1;t2] TC_fn))`;

val _ = Define `
 (Texn=  (Tapp [] TC_exn))`;


(* Patterns *)
val _ = Hol_datatype `
 pat =
    Pvar of varN
  | Plit of lit
  (* Constructor applications.
     A Nothing constructor indicates a tuple pattern. *)
  | Pcon of  ( (modN, conN)id)option => pat list
  | Pref of pat
  | Ptannot of pat => t`;


(* Expressions *)
val _ = Hol_datatype `
 exp =
    Raise of exp
  | Handle of exp => (pat # exp) list
  | Lit of lit
  (* Constructor application.
     A Nothing constructor indicates a tuple pattern. *)
  | Con of  ( (modN, conN)id)option => exp list
  | Var of (modN, varN) id
  | Fun of varN => exp
  (* Application of a primitive operator to arguments.
     Includes function application. *)
  | App of op => exp list
  (* Logical operations (and, or) *)
  | Log of lop => exp => exp
  | If of exp => exp => exp
  (* Pattern matching *)
  | Mat of exp => (pat # exp) list
  (* A let expression
     A Nothing value for the binding indicates that this is a
     sequencing expression, that is: (e1; e2). *)
  | Let of  varN option => exp => exp
  (* Local definition of (potentially) mutually recursive
     functions.
     The first varN is the function's name, and the second varN
     is its parameter. *)
  | Letrec of (varN # varN # exp) list => exp
  | Tannot of exp => t
  (* Location annotated expressions, not expected in source programs *)
  | Lannot of exp => locs`;


val _ = type_abbrev( "type_def" , ``: ( tvarN list # typeN # (conN # t list) list) list``);

(* Declarations *)
val _ = Hol_datatype `
 dec =
  (* Top-level bindings
   * The pattern allows several names to be bound at once *)
    Dlet of pat => exp
  (* Mutually recursive function definition *)
  | Dletrec of (varN # varN # exp) list
  (* Type definition
     Defines several data types, each of which has several
     named variants, which can in turn have several arguments.
   *)
  | Dtype of type_def
  (* Type abbreviations *)
  | Dtabbrev of tvarN list => typeN => t
  (* New exceptions *)
  | Dexn of conN => t list`;


val _ = type_abbrev( "decs" , ``: dec list``);

(* Specifications
   For giving the signature of a module *)
val _ = Hol_datatype `
 spec =
    Sval of varN => t
  | Stype of type_def
  | Stabbrev of tvarN list => typeN => t
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
 val pat_bindings_defn = Defn.Hol_multi_defns `

(pat_bindings (Pvar n) already_bound=  
 (n::already_bound))
/\
(pat_bindings (Plit l) already_bound= 
  already_bound)
/\
(pat_bindings (Pcon _ ps) already_bound=  
 (pats_bindings ps already_bound))
/\
(pat_bindings (Pref p) already_bound=  
 (pat_bindings p already_bound))
/\
(pat_bindings (Ptannot p _) already_bound=  
 (pat_bindings p already_bound))
/\
(pats_bindings [] already_bound= 
  already_bound)
/\
(pats_bindings (p::ps) already_bound=  
 (pats_bindings ps (pat_bindings p already_bound)))`;

val _ = Lib.with_flag (computeLib.auto_import_definitions, false) (List.map Defn.save_defn) pat_bindings_defn;
val _ = export_theory()

