(*Generated by Lem from semanticPrimitives.lem.*)
open HolKernel Parse boolLib bossLib;
open pervasives_extraTheory semanticPrimitivesTheory;

val _ = numLib.prefer_num();



val _ = new_theory "semanticPrimitivesAuxiliary"


(****************************************************)
(*                                                  *)
(* Termination Proofs                               *)
(*                                                  *)
(****************************************************)

(* val gst = Defn.tgoal_no_defn (pmatch_def, pmatch_ind) *)
val (pmatch_rw, pmatch_ind_rw) =
  Defn.tprove_no_defn ((pmatch_def, pmatch_ind),
    (* the termination proof *)
  )
val pmatch_rw = save_thm ("pmatch_rw", pmatch_rw);
val pmatch_ind_rw = save_thm ("pmatch_ind_rw", pmatch_ind_rw);


(* val gst = Defn.tgoal_no_defn (find_recfun_def, find_recfun_ind) *)
val (find_recfun_rw, find_recfun_ind_rw) =
  Defn.tprove_no_defn ((find_recfun_def, find_recfun_ind),
    (* the termination proof *)
  )
val find_recfun_rw = save_thm ("find_recfun_rw", find_recfun_rw);
val find_recfun_ind_rw = save_thm ("find_recfun_ind_rw", find_recfun_ind_rw);


(* val gst = Defn.tgoal_no_defn (contains_closure_def, contains_closure_ind) *)
val (contains_closure_rw, contains_closure_ind_rw) =
  Defn.tprove_no_defn ((contains_closure_def, contains_closure_ind),
    (* the termination proof *)
  )
val contains_closure_rw = save_thm ("contains_closure_rw", contains_closure_rw);
val contains_closure_ind_rw = save_thm ("contains_closure_ind_rw", contains_closure_ind_rw);


(* val gst = Defn.tgoal_no_defn (do_eq_def, do_eq_ind) *)
val (do_eq_rw, do_eq_ind_rw) =
  Defn.tprove_no_defn ((do_eq_def, do_eq_ind),
    (* the termination proof *)
  )
val do_eq_rw = save_thm ("do_eq_rw", do_eq_rw);
val do_eq_ind_rw = save_thm ("do_eq_ind_rw", do_eq_ind_rw);


(* val gst = Defn.tgoal_no_defn (decs_to_cenv_def, decs_to_cenv_ind) *)
val (decs_to_cenv_rw, decs_to_cenv_ind_rw) =
  Defn.tprove_no_defn ((decs_to_cenv_def, decs_to_cenv_ind),
    (* the termination proof *)
  )
val decs_to_cenv_rw = save_thm ("decs_to_cenv_rw", decs_to_cenv_rw);
val decs_to_cenv_ind_rw = save_thm ("decs_to_cenv_ind_rw", decs_to_cenv_ind_rw);




val _ = export_theory()

