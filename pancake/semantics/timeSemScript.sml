(*
  semantics for timeLang
*)

open preamble
     timeLangTheory

val _ = new_theory "timeSem";

Datatype:
  label = LDelay time
        | LAction ioAction
End

(*
   ; consumed : ioAction option
   ; output   : effect option ⇒
   ioAction   : ioAction
 *)

Datatype:
  store =
  <| clocks   : clock |-> time
   ; location : loc
   ; consumed : ioAction option
   ; output   : effect option
   ; waitTime : time option
  |>
End

Definition minusT_def:
  minusT (t1:time) (t2:time) = t1 - t2
End

Definition mkStore_def:
  mkStore cks loc ac eff wt =
  <| clocks   := cks
   ; location := loc
   ; consumed := ac
   ; output   := eff
   ; waitTime := wt
  |>
End

Definition resetOutput_def:
  resetOutput st =
  st with
  <| consumed := NONE
   ; output   := NONE
   ; waitTime := NONE
  |>
End


Definition resetClocks_def:
  resetClocks (st:store) cvs =
  let reset_cvs = MAP (λx. (x,0:time)) cvs in
      st with clocks := st.clocks |++ reset_cvs
End


Definition list_min_option_def:
  (list_min_option ([]:real list) = NONE) /\
  (list_min_option (x::xs) =
   case list_min_option xs of
   | NONE => SOME x
   | SOME y => SOME (if x < y then x else y))
End

Definition delay_clocks_def:
  delay_clocks fm d = fm |++
                         (MAP (λ(x,y). (x,y+d))
                          (fmap_to_alist fm))
End

Definition evalExpr_def:
  (evalExpr st (ELit t) = t) ∧
  (evalExpr st (ESub e1 e2) =
    minusT (evalExpr st e1) (evalExpr st e2)) ∧
  (evalExpr st (EClock c) =
    case FLOOKUP st.clocks c of
     | NONE => 0
     | SOME t => t)
End

Definition evalCond_def:
  (evalCond st (CndLe e1 e2) = (evalExpr st e1 <= evalExpr st e2)) /\
  (evalCond st (CndLt e1 e2) = (evalExpr st e1 < evalExpr st e2))
End

Definition evalDiff_def:
  evalDiff st ((t,c): time # clock) =
    evalExpr st (ESub (ELit t) (EClock c))
End


Definition calculate_wtime_def:
  calculate_wtime st clks diffs =
    list_min_option (MAP (evalDiff (resetClocks st clks)) diffs)
End

Inductive evalTerm:
  (∀st action cnds clks dest diffs.
     EVERY (λck. ck IN FDOM st.clocks) clks ==>
     evalTerm st (SOME action)
              (Tm (Input action)
                  cnds
                  clks
                  dest
                  diffs)
              (resetClocks
               (st with  <| consumed := SOME action
                          ; location := dest
                          ; waitTime := calculate_wtime st clks diffs|>)
               clks)) /\

  (∀st effect cnds clks dest diffs.
     EVERY (λck. ck IN FDOM st.clocks) clks ==>
     evalTerm st NONE
              (Tm (Output effect)
                  cnds
                  clks
                  dest
                  diffs)
              (resetClocks
               (st with  <| output   := SOME effect
                          ; location := dest
                          ; waitTime := calculate_wtime st clks diffs|>)
               clks))
End

Inductive pickTerm:
  (!st cnds event action clks dest diffs tms st'.
    EVERY (λcnd. evalCond st cnd) cnds /\
    event = SOME action /\
    evalTerm st event (Tm (Input action) cnds clks dest diffs) st' ==>
    pickTerm st event (Tm (Input action) cnds clks dest diffs :: tms) st') /\

  (!st cnds event effect clks dest diffs tms st'.
    EVERY (λcnd. evalCond st cnd) cnds /\
    event = NONE /\
    evalTerm st event (Tm (Output effect) cnds clks dest diffs) st' ==>
    pickTerm st event (Tm (Output effect) cnds clks dest diffs :: tms) st') /\

  (!st cnds event ioAction clks dest diffs tms st'.
    ~(EVERY (λcnd. evalCond st cnd) cnds) /\
    pickTerm st event tms st' ==>
    pickTerm st event (Tm ioAction cnds clks dest diffs :: tms) st') /\

  (!st cnds event action clks dest diffs tms st'.
    event <> SOME action /\
    pickTerm st event tms st' ==>
    pickTerm st event (Tm (Input action) cnds clks dest diffs :: tms) st') /\

  (!st cnds event effect clks dest diffs tms st'.
    event <> NONE /\
    pickTerm st event tms st' ==>
    pickTerm st event (Tm (Output effect) cnds clks dest diffs :: tms) st')
End

Inductive step:
  (!p st d.
    st.waitTime = NONE /\
    0 <= d ==>
    step p (LDelay d) st
         (mkStore
          (delay_clocks (st.clocks) d)
          st.location
          NONE
          NONE
          NONE)) /\

  (!p st d w.
    st.waitTime = SOME w /\
    0 <= d /\ d < w ==>
    step p (LDelay d) st
         (mkStore
          (delay_clocks (st.clocks) d)
          st.location
          NONE
          NONE
          (SOME (w - d)))) /\

  (!p st tms st' action.
      ALOOKUP p st.location = SOME tms /\
      pickTerm (resetOutput st) (SOME action) tms st' /\
      st'.consumed = SOME action /\
      st'.output = NONE ==>
      step p (LAction (Input action)) st st') /\

  (!p st tms st' effect.
      ALOOKUP p st.location = SOME tms /\
      pickTerm (resetOutput st) NONE tms st' /\
      st'.consumed = NONE /\
      st'.output = SOME effect ==>
      step p (LAction (Output effect)) st st')
End


Inductive stepTrace:
  (!p st.
    stepTrace p st st []) /\
  (!p lbl st st' st'' tr.
    step p lbl st st' /\
    stepTrace p st' st'' tr ==>
    stepTrace p st st'' (lbl::tr))
End

val _ = export_theory();
