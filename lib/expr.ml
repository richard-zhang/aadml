module IntMap = Map.Make (struct
  type t = int

  let compare = Int.compare
end)

type 'a env = 'a IntMap.t

let empty = IntMap.empty
let update = IntMap.add
let lookup key = IntMap.find key

type _ expr =
  | Const : 'a -> 'a expr
  | Mul : 'a expr * 'a expr -> 'a expr
  | Add : 'a expr * 'a expr -> 'a expr
  | Sub : 'a expr * 'a expr -> 'a expr
  | Div : 'a expr * 'a expr -> 'a expr
  | Sin : 'a expr -> 'a expr
  | Cos : 'a expr -> 'a expr
  | Ln : 'a expr -> 'a expr
  | E : 'a expr -> 'a expr
  | Zero : 'a expr
  | One : 'a expr
  | Var : int -> 'a expr

let unary_apply op eval a env = op (eval a env)
let binary_apply op eval a b env = op (eval a env) (eval b env)

let rec eval = function
  | Mul (a, b) -> binary_apply ( *. ) eval a b
  | Add (a, b) -> binary_apply ( +. ) eval a b
  | Sub (a, b) -> binary_apply ( -. ) eval a b
  | Div (a, b) -> binary_apply ( /. ) eval a b
  | Sin a -> unary_apply sin eval a
  | Cos a -> unary_apply cos eval a
  | Ln a -> unary_apply log eval a
  | E a -> unary_apply exp eval a
  | Zero -> fun _ -> 0.0
  | One -> fun _ -> 1.0
  | Const a -> fun _ -> a
  | Var int -> fun env -> lookup int env

let add a b = Add (a, b)
let mul a b = Mul (a, b)
let sub a b = Sub (a, b)
let div a b = Div (a, b)
let cos a = Cos a
let sin a = Sin a
let e a = E a
let ln a = Ln a
let zero = Zero
let one = One
let var id = Var id

let rec diff = function
  | Var x -> fun id -> if id = x then One else Zero
  | Zero -> fun _ -> Zero
  | One -> fun _ -> Zero
  | Const _ -> fun _ -> Zero
  | Mul (a, b) -> fun id -> Add (Mul (diff a id, b), Mul (diff b id, a))
  | Add (a, b) -> fun id -> Add (diff a id, diff b id)
  | Sub (a, b) -> fun id -> Sub (diff a id, diff b id)
  | Div (a, b) ->
      fun id ->
        let u'v = Mul (diff a id, b) in
        let uv' = Mul (a, diff b id) in
        Div (Sub (u'v, uv'), Mul (b, b))
  | Sin a -> fun id -> Mul (Cos a, diff a id)
  | Cos a -> fun id -> Sub (Zero, Mul (Sin a, diff a id))
  | E a -> fun id -> Mul (E a, diff a id)
  | Ln a -> fun id -> Mul (Div (One, a), diff a id)

let test_can_derv formula =
  let _ = diff formula 0 in
  [%test_eq: Base.float] 0.0 0.0

let%test_unit "const" = [%test_eq: Base.float] (eval (Const 1.0) empty) 1.0
let%test "const" = eval (Const 1.0) empty = 1.0

let test_simple formula a derv_a b derv_b =
  let fuzzy_comp a b =
    [%test_pred: Base.float] (fun a -> a < 0.000001) (abs_float (a -. b))
  in
  let env = empty |> update 0 a |> update 1 b in
  let diff_x0 = diff formula 0 in
  let diff_x1 = diff formula 1 in
  let diff_x0 = eval diff_x0 env in
  let diff_x1 = eval diff_x1 env in
  fuzzy_comp diff_x0 derv_a;
  fuzzy_comp diff_x1 derv_b

let%test_unit "smoke test" =
  let formula = var 0 in
  test_can_derv formula

let%test_unit "y=x_0" =
  let formula = var 0 in
  test_simple formula 3.0 1.0 1.0 0.0

let%test_unit "y = x_0 + x_1" =
  let formula = add (var 0) (var 1) in
  test_simple formula 3.0 1.0 1.0 1.0

let%test_unit "y = x_0 * x_1" =
  let formula = mul (var 0) (var 1) in
  test_simple formula 3.0 4.0 4.0 3.0

let%test_unit "complex formula" =
  let complex_formula =
    let x_0 = var 0 in
    let x_1 = var 1 in
    let x_01 = mul x_0 x_1 in
    let sin_x_0 = sin x_0 in
    let add_x01_sin = add x_01 sin_x_0 in
    let e = e add_x01_sin in
    let add_1_e = add one e in
    div one add_1_e
  in
  test_simple complex_formula 1.0 (-0.181974) 1.0 (-0.118142)