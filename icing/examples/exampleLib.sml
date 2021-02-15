(*
  Lib to prove examples
*)
structure exampleLib =
struct
  open astTheory cfTacticsLib ml_translatorLib;
  open basis_ffiTheory cfHeapsBaseTheory basis;
  open FloverMapTheory RealIntervalInferenceTheory ErrorIntervalInferenceTheory
       CertificateCheckerTheory;
  open floatToRealProofsTheory source_to_sourceTheory CakeMLtoFloVerTheory
       cfSupportTheory optPlannerTheory icing_realIdProofsTheory;
  open machine_ieeeTheory binary_ieeeTheory realTheory realLib RealArith;
  open supportLib;

  fun flatMap (ll:'a list list) =
    case ll of [] => []
    | l1 :: ls => l1 @ flatMap ls

  fun dedup l =
    case l of
    [] => []
    | l1::ls =>
        let val lclean = dedup ls in
          if (List.exists (fn x => x = l1) lclean)
          then lclean
          else l1::lclean
        end;

  val iter_code = process_topdecs ‘
    fun iter n s f =
      if (n = 0) then s else iter (n-1) (f s) f;’

  val iter_count = “10000000:int”

  fun main1 fname =
    “[Dlet unknown_loc (Pvar "main")
      (Fun "a"
       (Let (SOME "u") (Con NONE [])
        (Let (SOME "strArgs")
         (App Opapp [Var (Short "reader1"); Var (Short "u")])
         (Mat (Var (Short "strArgs"))
          [(Pvar "d1s",
            (Let (SOME "d1")
             (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
                (Let (SOME "x" )
                  (App Opapp [Var (Short ^fname); Var (Short "d1")])
                (Let (SOME "y")
                 (App FpToWord [Var (Short "x")])
                 (App Opapp [
                     Var (Short "printer");
                     Var (Short "y")])))))]))))]”;

  fun main2 fname =
    “[Dlet unknown_loc (Pvar "main")
      (Fun "a"
       (Let (SOME "u") (Con NONE [])
        (Let (SOME "strArgs")
         (App Opapp [Var (Short "reader2"); Var (Short "u")])
         (Mat (Var (Short "strArgs"))
          [(Pcon NONE [Pvar "d1s"; Pvar "d2s"],
            (Let (SOME "d1")
             (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
             (Let (SOME "d2")
              (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
                (Let (SOME "x" )
                  (App Opapp [
                          App Opapp [Var (Short ^fname); Var (Short "d1")];
                        Var (Short "d2")])
                (Let (SOME "y")
                 (App FpToWord [Var (Short "x")])
                 (App Opapp [
                     Var (Short "printer");
                     Var (Short "y")]))))))]))))]”;

  fun main3 fname =
    “[Dlet unknown_loc (Pvar "main")
      (Fun "a"
       (Let (SOME "u") (Con NONE [])
        (Let (SOME "strArgs")
         (App Opapp [Var (Short "reader3"); Var (Short "u")])
         (Mat (Var (Short "strArgs"))
          [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pvar "d3s"]],
            (Let (SOME "d1")
             (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
             (Let (SOME "d2")
              (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
              (Let (SOME "d3")
               (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
               (Let (SOME "x" )
                (App Opapp [
                    App Opapp [
                        App Opapp [Var (Short ^fname); Var (Short "d1")];
                        Var (Short "d2")];
                    Var (Short "d3")])
                (Let (SOME "y")
                 (App FpToWord [Var (Short "x")])
                 (App Opapp [
                     Var (Short "printer");
                     Var (Short "y")])))))))]))))]”;

  fun main4 fname =
  “[Dlet unknown_loc (Pvar "main")
    (Fun "a"
     (Let (SOME "u") (Con NONE [])
     (Let (SOME "strArgs")
      (App Opapp [Var (Short "reader4"); Var (Short "u")])
      (Mat (Var (Short "strArgs"))
       [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pcon NONE [Pvar "d3s"; Pvar "d4s"]]]),
         (Let (SOME "d1")
          (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
          (Let (SOME "d2")
           (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
           (Let (SOME "d3")
            (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
            (Let (SOME "d4")
             (App Opapp [Var (Short "intToFP"); Var (Short "d4s")])
             (Let (SOME "x" )
              (App Opapp [
                 App Opapp [
                   App Opapp [
                     App Opapp [Var (Short ^fname); Var (Short "d1")];
                     Var (Short "d2")];
                   Var (Short "d3")];
                 Var (Short "d4")])
             (Let (SOME "y")
              (App FpToWord [Var (Short "x")])
              (App Opapp [
                 Var (Short "printer");
                 Var (Short "y")])))))))]))))]”;

  fun main6 fname =
  “[Dlet unknown_loc (Pvar "main")
    (Fun "a"
     (Let (SOME "u") (Con NONE [])
     (Let (SOME "strArgs")
      (App Opapp [Var (Short "reader6"); Var (Short "u")])
      (Mat (Var (Short "strArgs"))
       [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pcon NONE [Pvar "d3s";
         Pcon NONE [Pvar "d4s"; Pcon NONE [Pvar "d5s"; Pvar "d6s"]]]]]),
         (Let (SOME "d1")
          (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
          (Let (SOME "d2")
           (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
           (Let (SOME "d3")
            (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
            (Let (SOME "d4")
             (App Opapp [Var (Short "intToFP"); Var (Short "d4s")])
             (Let (SOME "d5")
              (App Opapp [Var (Short "intToFP"); Var (Short "d5s")])
             (Let (SOME "d6")
              (App Opapp [Var (Short "intToFP"); Var (Short "d6s")])
             (Let (SOME "x" )
              (App Opapp [
                 App Opapp [
                   App Opapp [
                     App Opapp [
                       App Opapp [
                         App Opapp [Var (Short ^fname); Var (Short "d1")];
                         Var (Short "d2")];
                       Var (Short "d3")];
                     Var (Short "d4")];
                   Var (Short "d5")];
                 Var (Short "d6")])
             (Let (SOME "y")
              (App FpToWord [Var (Short "x")])
              (App Opapp [
                 Var (Short "printer");
                 Var (Short "y")])))))))))]))))]”;

  fun main8 fname =
  “[Dlet unknown_loc (Pvar "main")
    (Fun "a"
     (Let (SOME "u") (Con NONE [])
     (Let (SOME "strArgs")
      (App Opapp [Var (Short "reader8"); Var (Short "u")])
      (Mat (Var (Short "strArgs"))
       [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pcon NONE [Pvar "d3s";
         Pcon NONE [Pvar "d4s"; Pcon NONE [Pvar "d5s"; Pcon NONE [Pvar "d6s";
         Pcon NONE [Pvar "d7s"; Pvar "d8s"]]]]]]]),
         (Let (SOME "d1")
          (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
          (Let (SOME "d2")
           (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
           (Let (SOME "d3")
            (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
            (Let (SOME "d4")
             (App Opapp [Var (Short "intToFP"); Var (Short "d4s")])
             (Let (SOME "d5")
              (App Opapp [Var (Short "intToFP"); Var (Short "d5s")])
             (Let (SOME "d6")
              (App Opapp [Var (Short "intToFP"); Var (Short "d6s")])
              (Let (SOME "d7")
               (App Opapp [Var (Short "intToFP"); Var (Short "d7s")])
                (Let (SOME "d8")
                 (App Opapp [Var (Short "intToFP"); Var (Short "d8s")])
             (Let (SOME "x" )
              (App Opapp [
                 App Opapp [
                   App Opapp [
                     App Opapp [
                       App Opapp [
                         App Opapp [
                           App Opapp [
                             App Opapp [Var (Short ^fname); Var (Short "d1")];
                             Var (Short "d2")];
                           Var (Short "d3")];
                         Var (Short "d4")];
                       Var (Short "d5")];
                     Var (Short "d6")];
                   Var (Short "d7")];
                 Var (Short "d8")])
             (Let (SOME "y")
              (App FpToWord [Var (Short "x")])
              (App Opapp [
                 Var (Short "printer");
                 Var (Short "y")])))))))))))]))))]”;

  fun main9 fname =
  “[Dlet unknown_loc (Pvar "main")
    (Fun "a"
     (Let (SOME "u") (Con NONE [])
     (Let (SOME "strArgs")
      (App Opapp [Var (Short "reader9"); Var (Short "u")])
      (Mat (Var (Short "strArgs"))
       [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pcon NONE [Pvar "d3s";
         Pcon NONE [Pvar "d4s"; Pcon NONE [Pvar "d5s"; Pcon NONE [Pvar "d6s";
         Pcon NONE [Pvar "d7s"; Pcon NONE [Pvar "d8s"; Pvar "d9s"]]]]]]]]),
         (Let (SOME "d1")
          (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
          (Let (SOME "d2")
           (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
           (Let (SOME "d3")
            (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
            (Let (SOME "d4")
             (App Opapp [Var (Short "intToFP"); Var (Short "d4s")])
             (Let (SOME "d5")
              (App Opapp [Var (Short "intToFP"); Var (Short "d5s")])
             (Let (SOME "d6")
              (App Opapp [Var (Short "intToFP"); Var (Short "d6s")])
              (Let (SOME "d7")
               (App Opapp [Var (Short "intToFP"); Var (Short "d7s")])
                (Let (SOME "d8")
                 (App Opapp [Var (Short "intToFP"); Var (Short "d8s")])
                  (Let (SOME "d9")
                   (App Opapp [Var (Short "intToFP"); Var (Short "d9s")])
             (Let (SOME "x" )
              (App Opapp [
                 App Opapp [
                   App Opapp [
                     App Opapp [
                       App Opapp [
                         App Opapp [
                           App Opapp [
                             App Opapp [
                               App Opapp [Var (Short ^fname); Var (Short "d1")];
                               Var (Short "d2")];
                             Var (Short "d3")];
                           Var (Short "d4")];
                         Var (Short "d5")];
                       Var (Short "d6")];
                     Var (Short "d7")];
                   Var (Short "d8")];
                 Var (Short "d9")])
             (Let (SOME "y")
              (App FpToWord [Var (Short "x")])
              (App Opapp [
                 Var (Short "printer");
                 Var (Short "y")]))))))))))))]))))]”;

  fun call1_code fname = Parse.Term ‘
    [Dlet unknown_loc (Pvar "it")
     (Let (SOME "u") (App FpFromWord [Lit (Word64 (4613937818241073152w:word64))])
      (Let (SOME "strArgs")
       (App Opapp [Var (Short "reader1"); Var (Short "u")])
       (Mat (Var (Short "strArgs"))
        [(Pvar "d1s",
          (Let (SOME "d1")
           (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
            (Let (SOME "b")
               (Fun "x"
               (Let (SOME "y")
                (App Opapp [
                          Var (Short ^fname); Var (Short "d1")])
                (Var (Short "y"))))
              (App Opapp [
                  App Opapp [
                      App Opapp [Var (Short "iter"); Lit (IntLit ^iter_count)];
                      Var (Short "u")]; Var (Short "b")]))))])))]’;

  fun call2_code fname = Parse.Term ‘
    [Dlet unknown_loc (Pvar "it")
     (Let (SOME "u") (App FpFromWord [Lit (Word64 (4613937818241073152w:word64))])
      (Let (SOME "strArgs")
       (App Opapp [Var (Short "reader2"); Var (Short "u")])
       (Mat (Var (Short "strArgs"))
        [(Pcon NONE [Pvar "d1s"; Pvar "d2s"],
          (Let (SOME "d1")
           (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
           (Let (SOME "d2")
            (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
             (Let (SOME "b")
              (Fun "x"
               (Let (SOME "y")
                (App Opapp [
                          App Opapp [Var (Short ^fname); Var (Short "d1")];
                        Var (Short "d2")])
                (Var (Short "y"))))
              (App Opapp [
                  App Opapp [
                      App Opapp [Var (Short "iter"); Lit (IntLit ^iter_count)];
                      Var (Short "u")]; Var (Short "b")])))))])))]’;

  fun call3_code fname = Parse.Term ‘
    [Dlet unknown_loc (Pvar "it")
     (Let (SOME "u") (App FpFromWord [Lit (Word64 (4613937818241073152w:word64))])
      (Let (SOME "strArgs")
       (App Opapp [Var (Short "reader3"); Var (Short "u")])
       (Mat (Var (Short "strArgs"))
        [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pvar "d3s"]],
          (Let (SOME "d1")
           (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
           (Let (SOME "d2")
            (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
            (Let (SOME "d3")
             (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
             (Let (SOME "b")
              (Fun "x"
               (Let (SOME "y")
                (App Opapp [
                    App Opapp [
                        App Opapp [Var (Short ^fname); Var (Short "d1")];
                        Var (Short "d2")];
                    Var (Short "d3")])
                (Var (Short "y"))))
              (App Opapp [
                  App Opapp [
                      App Opapp [Var (Short "iter"); Lit (IntLit ^iter_count)];
                      Var (Short "u")]; Var (Short "b")]))))))])))]’;

  fun call4_code fname = Parse.Term ‘
      [Dlet unknown_loc (Pvar "it")
  (Let (SOME "u") (App FpFromWord [Lit (Word64 (4613937818241073152w:word64))])
   (Let (SOME "strArgs")
    (App Opapp [Var (Short "reader4"); Var (Short "u")])
    (Mat (Var (Short "strArgs"))
       [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pcon NONE [Pvar "d3s"; Pvar "d4s"]]]),
         (Let (SOME "d1")
          (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
          (Let (SOME "d2")
           (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
           (Let (SOME "d3")
            (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
            (Let (SOME "d4")
             (App Opapp [Var (Short "intToFP"); Var (Short "d4s")])
          (Let (SOME "b")
           (Fun "x"
            (Let (SOME "y")
             (App Opapp [
             App Opapp [
                App Opapp [
                  App Opapp [Var (Short ^fname); Var (Short "d1")];
                  Var (Short "d2")];
                Var (Short "d3")];
                Var (Short "d4")])
             (Var (Short "y"))))
           (App Opapp [
              App Opapp [
                App Opapp [Var (Short "iter"); Lit (IntLit ^iter_count)];
                Var (Short "u")]; Var (Short "b")]))))))])))]’;

  fun call6_code fname = Parse.Term ‘
      [Dlet unknown_loc (Pvar "it")
  (Let (SOME "u") (App FpFromWord [Lit (Word64 (4613937818241073152w:word64))])
   (Let (SOME "strArgs")
    (App Opapp [Var (Short "reader6"); Var (Short "u")])
    (Mat (Var (Short "strArgs"))
       [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pcon NONE [Pvar "d3s";
         Pcon NONE [Pvar "d4s"; Pcon NONE [Pvar "d5s"; Pvar "d6s"]]]]]),
         (Let (SOME "d1")
          (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
          (Let (SOME "d2")
           (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
           (Let (SOME "d3")
            (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
            (Let (SOME "d4")
             (App Opapp [Var (Short "intToFP"); Var (Short "d4s")])
             (Let (SOME "d5")
              (App Opapp [Var (Short "intToFP"); Var (Short "d5s")])
             (Let (SOME "d6")
              (App Opapp [Var (Short "intToFP"); Var (Short "d6s")])
          (Let (SOME "b")
           (Fun "x"
            (Let (SOME "y")
             (App Opapp [
             App Opapp [
                App Opapp [
                  App Opapp [
                    App Opapp [
                      App Opapp [Var (Short ^fname); Var (Short "d1")];
                      Var (Short "d2")];
                    Var (Short "d3")];
                    Var (Short "d4")];
                  Var (Short "d5")];
                Var (Short "d6")])
             (Var (Short "y"))))
           (App Opapp [
              App Opapp [
                App Opapp [Var (Short "iter"); Lit (IntLit ^iter_count)];
                Var (Short "u")]; Var (Short "b")]))))))))])))]’;

  fun call8_code fname = Parse.Term ‘
      [Dlet unknown_loc (Pvar "it")
  (Let (SOME "u") (App FpFromWord [Lit (Word64 (4613937818241073152w:word64))])
   (Let (SOME "strArgs")
    (App Opapp [Var (Short "reader8"); Var (Short "u")])
    (Mat (Var (Short "strArgs"))
       [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pcon NONE [Pvar "d3s";
         Pcon NONE [Pvar "d4s"; Pcon NONE [Pvar "d5s"; Pcon NONE [Pvar "d6s";
         Pcon NONE [Pvar "d7s"; Pvar "d8s"]]]]]]]),
         (Let (SOME "d1")
          (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
          (Let (SOME "d2")
           (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
           (Let (SOME "d3")
            (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
            (Let (SOME "d4")
             (App Opapp [Var (Short "intToFP"); Var (Short "d4s")])
             (Let (SOME "d5")
              (App Opapp [Var (Short "intToFP"); Var (Short "d5s")])
             (Let (SOME "d6")
              (App Opapp [Var (Short "intToFP"); Var (Short "d6s")])
              (Let (SOME "d7")
               (App Opapp [Var (Short "intToFP"); Var (Short "d7s")])
                (Let (SOME "d8")
                 (App Opapp [Var (Short "intToFP"); Var (Short "d8s")])
          (Let (SOME "b")
           (Fun "x"
            (Let (SOME "y")
              (App Opapp [
                 App Opapp [
                   App Opapp [
                     App Opapp [
                       App Opapp [
                         App Opapp [
                           App Opapp [
                             App Opapp [Var (Short ^fname); Var (Short "d1")];
                             Var (Short "d2")];
                           Var (Short "d3")];
                         Var (Short "d4")];
                       Var (Short "d5")];
                     Var (Short "d6")];
                   Var (Short "d7")];
                 Var (Short "d8")])
               (Var (Short "y"))))
           (App Opapp [
              App Opapp [
                App Opapp [Var (Short "iter"); Lit (IntLit ^iter_count)];
                Var (Short "u")]; Var (Short "b")]))))))))))])))]’;

  fun call9_code fname = Parse.Term ‘
      [Dlet unknown_loc (Pvar "it")
  (Let (SOME "u") (App FpFromWord [Lit (Word64 (4613937818241073152w:word64))])
   (Let (SOME "strArgs")
    (App Opapp [Var (Short "reader9"); Var (Short "u")])
    (Mat (Var (Short "strArgs"))
       [(Pcon NONE [Pvar "d1s"; Pcon NONE [Pvar "d2s"; Pcon NONE [Pvar "d3s";
         Pcon NONE [Pvar "d4s"; Pcon NONE [Pvar "d5s"; Pcon NONE [Pvar "d6s";
         Pcon NONE [Pvar "d7s"; Pcon NONE [Pvar "d8s"; Pvar "d9s"]]]]]]]]),
         (Let (SOME "d1")
          (App Opapp [Var (Short "intToFP"); Var (Short "d1s")])
          (Let (SOME "d2")
           (App Opapp [Var (Short "intToFP"); Var (Short "d2s")])
           (Let (SOME "d3")
            (App Opapp [Var (Short "intToFP"); Var (Short "d3s")])
            (Let (SOME "d4")
             (App Opapp [Var (Short "intToFP"); Var (Short "d4s")])
             (Let (SOME "d5")
              (App Opapp [Var (Short "intToFP"); Var (Short "d5s")])
             (Let (SOME "d6")
              (App Opapp [Var (Short "intToFP"); Var (Short "d6s")])
              (Let (SOME "d7")
               (App Opapp [Var (Short "intToFP"); Var (Short "d7s")])
                (Let (SOME "d8")
                 (App Opapp [Var (Short "intToFP"); Var (Short "d8s")])
                  (Let (SOME "d9")
                   (App Opapp [Var (Short "intToFP"); Var (Short "d9s")])
          (Let (SOME "b")
           (Fun "x"
            (Let (SOME "y")
              (App Opapp [
                 App Opapp [
                   App Opapp [
                     App Opapp [
                       App Opapp [
                         App Opapp [
                           App Opapp [
                             App Opapp [
                               App Opapp [Var (Short ^fname); Var (Short "d1")];
                               Var (Short "d2")];
                             Var (Short "d3")];
                           Var (Short "d4")];
                         Var (Short "d5")];
                       Var (Short "d6")];
                     Var (Short "d7")];
                   Var (Short "d8")];
                 Var (Short "d9")])
               (Var (Short "y"))))
           (App Opapp [
              App Opapp [
                App Opapp [Var (Short "iter"); Lit (IntLit ^iter_count)];
                Var (Short "u")]; Var (Short "b")])))))))))))])))]’;

  fun define_benchmark theAST_def theAST_pre_def checkError =
  let
    val theAST = theAST_def |> concl |> rhs
    val theAST_pre = theAST_pre_def |> concl |> rhs
    (** Optimizations to be applied by Icing **)
    val theOpts_def = Define ‘theOpts = no_fp_opt_conf’
    val theAST_plan_def = Define ‘theAST_plan = generate_plan_decs theOpts theAST’
    val theAST_plan_result = save_thm ("theAST_plan_result", EVAL (Parse.Term ‘theAST_plan’));
    val thePlan_def = EVAL “HD ^(theAST_plan_result |> concl |> rhs)”
    val hotRewrites = thePlan_def |> concl |> rhs |> listSyntax.dest_list |> #1
                      |> map (fn t => EVAL “case ^t of | Apply (_, rws) => rws | _ => [] ”
                                |> concl |> rhs |> listSyntax.dest_list |> #1)
                      |> flatMap
                      |> map (fn t => DB.apropos_in t (DB.thy "icing_optimisations"))
                      |> flatMap
                      |> map (#2 o #1)
                      |> dedup
                      |> List.foldl (fn (elem, acc) => acc ^ " " ^ elem ^ " ;") "Used rewrites:"
    val _ = adjoin_to_theory
             { sig_ps =
            SOME (fn _ => PP.add_string
                      ("(* "^hotRewrites^" *)")),
            struct_ps = NONE };
  (** The code below stores in theorem theAST_opt the optimized version of the AST
      from above and in errorbounds_AST the inferred FloVer roundoff error bounds
   **)
  val theAST_opt_result = save_thm ("theAST_opt_result",
    EVAL
      (Parse.Term ‘
        MAP SND (stos_pass_with_plans_decs theOpts theAST_plan theAST)’));
  val _ = if Term.compare (theAST_opt_result |> concl |> rhs,“[source_to_source$Success]”) <> EQUAL
          then raise ERR ("Failed optimization with error:"^
                          (Parse.thm_to_string theAST_opt_result)) ""
          else ()
  val theAST_opt = save_thm ("theAST_opt",
    EVAL
      (Parse.Term ‘
        (no_opt_decs theOpts (MAP FST (stos_pass_with_plans_decs theOpts theAST_plan theAST)))’));
    val (fname_opt, fvars_opt, body_opt) =
      EVAL (Parse.Term ‘getDeclLetParts ^(theAST_opt |> concl |> rhs)’)
      |> concl |> rhs |> dest_pair
      |> (fn (x,y) => let val (y,z) = dest_pair y in (x,y,z) end)
    val (fname, fvars, body) =
      EVAL (Parse.Term ‘getDeclLetParts theAST’)
      |> concl |> rhs |> dest_pair
      |> (fn (x,y) => let val (y,z) = dest_pair y in (x,y,z) end)
    val numArgs = EVAL “LENGTH ^fvars” |> concl
                  |> rhs
                  |> numSyntax.dest_numeral
                  |>  Arbnumcore.toInt
    val (theMain, call_code, reader_def) =
      if numArgs = 1 then (main1 fname, call1_code fname, reader1_def)
      else if numArgs = 2 then (main2 fname, call2_code fname, reader2_def)
      else if numArgs = 3 then (main3 fname, call3_code fname, reader3_def)
      else if numArgs = 4 then (main4 fname, call4_code fname, reader4_def)
      else if numArgs = 6 then (main6 fname, call6_code fname, reader6_def)
      else if numArgs = 8 then (main8 fname, call8_code fname, reader8_def)
      else if numArgs = 9 then (main9 fname, call9_code fname, reader9_def)
      else raise ERR ("Too many arguments:"^(Int.toString numArgs)) ""
  val doppler_opt = theAST_opt |> concl |> rhs;
  val theProg_def = Define ‘theProg = ^theAST’
  val theOptProg_def = Define ‘theOptProg = ^doppler_opt’;
  val theBenchmarkMain_def = Define ‘theBenchmarkMain =
   (HD (^iter_code)) :: (^call_code  )’;
  val st_no_doppler = get_ml_prog_state ();
  val theAST_env = st_no_doppler
   |> ml_progLib.clean_state
   |> ml_progLib.remove_snocs
   |> ml_progLib.get_env;
  val _ = append_prog (theOptProg_def |> concl |> rhs)
  val _ = append_prog theMain;
  val theAST_env_def = Define ‘theAST_env = ^theAST_env’;
  (* val _ = computeLib.del_funs [sptreeTheory.subspt_def]; *)
  val _ = computeLib.add_funs [realTheory.REAL_INV_1OVER,
                             binary_ieeeTheory.float_to_real_def,
                             binary_ieeeTheory.float_tests,
                             sptreeTheory.subspt_eq,
                             sptreeTheory.lookup_def];
  val errorbounds_AST = if checkError
    then save_thm ("errorbounds_AST",
        EVAL (Parse.Term
          ‘isOkError ^(concl theAST_opt |> rhs) theAST_pre theErrBound’))
    else CONJ_COMM
  val local_opt_thm = save_thm ("local_opt_thm", mk_local_opt_thm theAST_opt theAST_def);
  val _ =
   supportLib.write_code_to_file true theAST_def theAST_opt
  (Parse.Term ‘APPEND ^(reader_def |> concl |> rhs) (APPEND ^(intToFP_def |> concl |> rhs) (APPEND ^(printer_def |> concl |> rhs) ^(theBenchmarkMain_def |> concl |> rhs)))’)
  (Parse.Term ‘APPEND ^(reader_def |> concl |> rhs) (APPEND ^(intToFP_def |> concl |> rhs) (APPEND ^(printer_def |> concl |> rhs) ^(theBenchmarkMain_def |> concl |> rhs)))’)
    (stringSyntax.fromHOLstring fname) numArgs;
  (* Plan correctness theorem *)
  val plan_list = theAST_plan_result |> concl |> rhs (* Get the actual plan *)
                   |> listSyntax.dest_list (* get the single plan *)
                   |> (fn (ts, tp) => if (length ts <> 1) then raise ERR "Too many plans constructed" ""
                                        else hd ts)
                   |> listSyntax.dest_list (* extract the plan as a list *)
                   |> #1 (* take the list, ignore type *)
  (* val stos_pass_correct_thm = save_thm ("stos_pass_correct_thm", mk_stos_pass_correct_thm plan_list)
  val stos_pass_real_id_thm = save_thm ("stos_pass_real_id_thm", mk_stos_pass_real_id_thm plan_list) *)
  in () end;

end;