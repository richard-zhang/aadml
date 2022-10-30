module IntMap : Map.S with type key = int

type 'a env = 'a IntMap.t

val empty : 'a env
val update : int -> 'a -> 'a env -> 'a env
val lookup : int -> 'a env -> 'a

type ('tag, _) tag_expr =
  | Const : 'tag * float -> ('tag, float) tag_expr
  | Mul :
      'tag * ('tag, 'a) tag_expr * ('tag, 'a) tag_expr
      -> ('tag, 'a) tag_expr
  | Add :
      'tag * ('tag, 'a) tag_expr * ('tag, 'a) tag_expr
      -> ('tag, 'a) tag_expr
  | Sub :
      'tag * ('tag, 'a) tag_expr * ('tag, 'a) tag_expr
      -> ('tag, 'a) tag_expr
  | Div :
      'tag * ('tag, 'a) tag_expr * ('tag, 'a) tag_expr
      -> ('tag, 'a) tag_expr
  | Sin : 'tag * ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
  | Cos : 'tag * ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
  | Ln : 'tag * ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
  | E : 'tag * ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
  | Sqrt : 'tag * ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
  | Zero : 'tag -> ('tag, 'a) tag_expr
  | One : 'tag -> ('tag, 'a) tag_expr
  | Var : 'tag * int -> ('tag, 'a) tag_expr
  | Max :
      'tag * ('tag, 'a) tag_expr * ('tag, 'a) tag_expr
      -> ('tag, 'a) tag_expr
  | Min :
      'tag * ('tag, 'a) tag_expr * ('tag, 'a) tag_expr
      -> ('tag, 'a) tag_expr
  | Not : 'tag * ('tag, bool) tag_expr -> ('tag, bool) tag_expr
  | And :
      'tag * ('tag, bool) tag_expr * ('tag, bool) tag_expr
      -> ('tag, bool) tag_expr
  | Or :
      'tag * ('tag, bool) tag_expr * ('tag, bool) tag_expr
      -> ('tag, bool) tag_expr
  | Equal :
      'tag * ('tag, 'a) tag_expr * ('tag, 'a) tag_expr
      -> ('tag, bool) tag_expr
  | Less :
      'tag * ('tag, 'a) tag_expr * ('tag, 'a) tag_expr
      -> ('tag, bool) tag_expr
  | IfThenElse :
      'tag * ('tag, bool) tag_expr * ('tag, 'a) tag_expr * ('tag, 'a) tag_expr
      -> ('tag, 'a) tag_expr

type ('tag, 'a) nullary = { op : 'elt. ('tag, 'elt) tag_expr -> 'a }
type ('tag, 'a) unary = { op : 'elt. ('tag, 'elt) tag_expr -> 'a -> 'a }
type ('tag, 'a) binary = { op : 'elt. ('tag, 'elt) tag_expr -> 'a -> 'a -> 'a }

val get_tag : ('tag, 'b) tag_expr -> 'tag

val fold_cps :
  (('tag, 'a) tag_expr -> 'b -> 'b -> 'b) ->
  (('tag, 'a) tag_expr -> 'b -> 'b) ->
  (('tag, 'a) tag_expr -> 'b) ->
  ('tag, 'a) tag_expr ->
  ('b -> 'c) ->
  'c

type 'a expr = (unit, 'a) tag_expr

val add : 'a expr -> 'a expr -> 'a expr
val mul : 'a expr -> 'a expr -> 'a expr
val sub : 'a expr -> 'a expr -> 'a expr
val div : 'a expr -> 'a expr -> 'a expr
val cos : 'a expr -> 'a expr
val sin : 'a expr -> 'a expr
val e : 'a expr -> 'a expr
val ln : 'a expr -> 'a expr
val sqrt : 'a expr -> 'a expr
val zero : 'a expr
val one : 'a expr
val var : int -> 'a expr
val const : float -> float expr
val neg : 'a expr -> 'a expr
val power : int -> 'a expr -> 'a expr

val add_tag :
  'tag -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr

val mul_tag :
  'tag -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr

val sub_tag :
  'tag -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr

val div_tag :
  'tag -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr

val cos_tag : 'tag -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
val sin_tag : 'tag -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
val e_tag : 'tag -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
val ln_tag : 'tag -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
val sqrt_tag : 'tag -> ('tag, 'a) tag_expr -> ('tag, 'a) tag_expr
val zero_tag : 'tag -> ('tag, 'a) tag_expr
val one_tag : 'tag -> ('tag, 'a) tag_expr
val var_tag : 'tag -> int -> ('tag, 'a) tag_expr
val const_tag : 'tag -> float -> ('tag, float) tag_expr

val eval : float env -> float expr -> float
(** naive evaluation implemented via tree traversal *)

val string_of_op : show:('a -> string) -> 'a expr -> string
