(*
The MIT License (MIT)

Copyright (c) 2014 Leonardo Laguna Ruiz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*)

open Code
open Config

module Templates = struct

   let none code = [ code, FileKind.ExtOnly "java"]

   let runtime : Pla.t =
      (*
      Pla.string
         {| // Vult runtime functions
            this.random = function()         { return Math.random(); };
            this.irandom = function()        { return Math.floor(Math.random() * 4294967296); };
            this.eps  = function()           { return 1e-18 };
            this.pi   = function()           { return 3.1415926535897932384; }
            this.clip = function(x,low,high) { return x<low?low:(x>high?high:x); };
            this.not  = function(x)          { return x==0?1:0; };
            this.real = function(x)          { return x; };
            this.int  = function(x)          { return x|0; };
            this.sin  = function(x)          { return Math.sin(x); };
            this.cos  = function(x)          { return Math.cos(x); };
            this.abs  = function(x)          { return Math.abs(x); };
            this.exp  = function(x)          { return Math.exp(x); };
            this.floor= function(x)          { return Math.floor(x); };
            this.tan  = function(x)          { return Math.tan(x); };
            this.tanh = function(x)          { return Math.tanh(x); };
            this.sqrt = function(x)          { return x; };
            this.set  = function(a, i, v)    { a[i]=v; };
            this.get  = function(a, i)       { return a[i]; };
            this.int_to_float = function(i)  { return i; };
            this.float_to_int = function(i)  { return Math.floor(i); };
            this.makeArray = function(size, v){ var a = new Array(size); for(var i=0;i<size;i++) a[i]=v; return a; };
            this.wrap_array = function(a) { return a; }
            this.log = function(x) { console.log(x); }
         |}
         *)
      {pla|
class _tuple___real_real__ {
   public float field_0;
   public float field_1;

   public _tuple___real_real__() {
      this.field_0 = 0.0f;
      this.field_1 = 0.0f;
   }

   public _tuple___real_real__(float field_0, float field_1) {
      this.field_0 = field_0;
      this.field_1 = field_1;
   }
};

_tuple___real_real__ split(float x) {
   double integer = Math.floor(x);
   double fractional = x - integer;
   return new _tuple___real_real__((float)integer, (float)fractional);
}

int clip(int x, int minv, int maxv) {
   if(x > maxv)
      return maxv;
   else if(x < minv)
      return minv;
   else return x;
}

float clip(float x, float minv, float maxv) {
   if(x > maxv)
      return maxv;
   else if(x < minv)
      return minv;
   else return x;
}

int[] makeArray(int size, int init) {
   int a[] = new int[size];
   Arrays.fill(a, init);
   return a;
}

float[] makeArray(int size, float init) {
   float a[] = new float[size];
   Arrays.fill(a, init);
   return a;
}

boolean not(boolean x) {
   return !x;
}

float tanh(float x) {
   return (float)Math.tanh(x);
}

float cos(float x) {
   return (float)Math.cos(x);
}

float sin(float x) {
   return (float)Math.sin(x);
}

float exp(float x) {
   return (float)Math.exp(x);
}

float int_to_float(int x) {
   return (float)x;
}

int float_to_int(float x) {
   return (int)x;
}

float cosh(float x) {
   return (float)Math.cosh(x);
}

float sinh(float x) {
   return (float)Math.sinh(x);
}

float tan(float x) {
   return (float)Math.tan(x);
}

float sqrt(float x) {
   return (float)Math.sqrt(x);
}

float pow(float x, float y) {
   return (float)Math.pow(x, y);
}

float floor(float x) {
   return (float)Math.floor(x);
}

static Random rand = new Random();

float random() {
   return rand.nextFloat();
}

float get(float[] a, int i) {
   return a[i];
}

void set(float[] a, int i, float val) {
   a[i] = val;
}

int get(int[] a, int i) {
   return a[i];
}

void set(int[] a, int i, int val) {
   a[i] = val;
}

float[] wrap_array(float x[]) {
   return x;
}

int[] wrap_array(int x[]) {
   return x;
}

|pla}

   let common module_name code =
      [{pla|
import java.util.Arrays;
import java.util.Random;

class <#module_name#s> {
<#runtime#>
<#code#>
}|pla},
       FileKind.ExtOnly "java"]

   let apply (_params:params) (module_name:string) (template:string) (code:Pla.t) : (Pla.t * FileKind.t) list =
      match template with
      | _ -> common module_name code

end

let dot = Pla.map_sep (Pla.string ".") Pla.string

(** Returns true if the expression is simple and does not need parenthesis *)
let isSimple (e:cexp) : bool =
   match e with
   | CEInt _
   | CEFloat _
   | CEBool _
   | CEString _
   | CECall _
   | CEIndex _
   | CEVar _ -> true
   | _ -> false

(** Returns the base type name and a list of its sizes *)
let rec simplifyArray (typ:type_descr) : string * string list =
   match typ with
   | CTSimple(name) -> name, []
   | CTArray(sub, size) ->
      let name, sub_size = simplifyArray sub in
      name, sub_size @ [string_of_int size]

(** Returns the representation of a type description *)
let printTypeDescr (typ:type_descr) : Pla.t =
   let kind, sizes = simplifyArray typ in
   match sizes with
   | [] -> Pla.string kind
   | _ ->
      {pla|<#kind#s>[]|pla}

let rec getInitValue (descr:type_descr) : Pla.t =
   match descr with
   | CTSimple("int") -> Pla.string "0"
   | CTSimple("abstract") -> Pla.string "0"
   | CTSimple("float") -> Pla.string  "0.0f"
   | CTSimple("real") -> Pla.string  "0.0"
   | CTSimple("boolean") -> Pla.string  "false"
   | CTSimple("unit") -> Pla.string  "0"
   | CTArray(typ, size) ->
      let init = getInitValue typ in
      let typ_t = printTypeDescr typ in
      if size < 32 then
         let elems = (CCList.init size (fun _ -> init) |> Pla.join_sep Pla.comma) in
         {pla|new <#typ_t#>[]{<#elems#>}|pla}
      else
         {pla|makeArray(<#size#i>,<#init#>)|pla}
   | CTSimple(name) -> {pla|new <#name#s>()|pla}

(** Used to print declarations and rebindings of lhs variables *)
let printTypeAndName (is_decl:bool) (typ:type_descr list) (name:string list) : Pla.t =
   match typ, name with
   | [typ], [name] ->
      let kind, sizes = simplifyArray typ in
      begin match is_decl, sizes with
         (* Simple varible declaration (no sizes) *)
         | true, [] -> {pla|<#kind#s> <#name#s>|pla}
         (* Array declarations (with sizes) *)
         | true, _  ->
            (*let t_sizes = Pla.map_sep Pla.comma Pla.string sizes in*)
            {pla|<#kind#s> <#name#s>[]|pla}
         (* Simple rebinding (no declaration) *)
         | _, _ -> {pla|<#name#s>|pla}
      end
   | _ -> failwith "CodeC.printTypeAndName: invalid input"

(** Used to print assignments of a tuple field to a variable *)
let printLhsExpTuple (var:string list) (is_var:bool) (i:int) (e:clhsexp) : Pla.t =
   let var = dot var in
   match e with
   (* Assigning to a simple variable *)
   | CLId(CTSimple typ :: _, name) ->
      let name_ = dot name in
      if is_var then (* with declaration *)
         {pla|<#typ#s> <#name_#> = <#var#>.field_<#i#i>;|pla}
      else (* with no declaration *)
         {pla|<#name_#> = <#var#>.field_<#i#i>;|pla}

   | CLId(typ, name) ->
      let tdecl = printTypeAndName is_var typ name in
      {pla|<#tdecl#> = <#var#>.field_<#i#i>;|pla}

   | CLWild -> Pla.unit

   | _ -> failwith ("printLhsExpTuple: All other cases should be already covered\n" ^ (Code.show_clhsexp e))


(** Returns a template the print the expression *)
let rec printExp (params:params) (e:cexp) : Pla.t =
   match e with
   | CEEmpty -> Pla.unit
   | CEFloat(s, _) -> Pla.string s

   | CEInt(n) ->
      (** Parenthesize if it has a unary minus *)
      if n < 0 then
         Pla.parenthesize (Pla.int n)
      else
         Pla.int n
   | CEBool(v) -> Pla.string (if v then "true" else "false")

   | CEString(s) -> Pla.string_quoted s

   | CEArray(elems, _) ->
      let telems = Pla.map_sep Pla.comma (printExp params) elems in
      {pla|{<#telems#>}|pla}

   | CECall(name, args, _) ->
      let targs = Pla.map_sep Pla.comma (printExp params) args in
      {pla|<#name#s>(<#targs#>)|pla}

   | CEUnOp(op, e, _) ->
      let te = printExp params e in
      {pla|(<#op#s> <#te#>)|pla}

   | CEOp(op, elems, _) ->
      let sop = {pla| <#op#s> |pla} in
      let telems = Pla.map_sep sop (printExp params) elems in
      {pla|(<#telems#>)|pla}

   | CEVar(name, _) ->
      dot name

   | CEIndex(e, index, _) ->
      let index = printExp params index in
      let e = printExp params e in
      {pla|<#e#>[<#index#>]|pla}

   | CEIf(cond, then_, else_, _) ->
      let tcond = printExp params cond in
      let tthen = printExp params then_ in
      let telse = printExp params else_ in
      {pla|(<#tcond#>?<#tthen#>:<#telse#>)|pla}

   | CETuple(elems, CTSimple name) ->
      let telems = Pla.map_sep Pla.comma (printChField params) elems in
      {pla|new <#name#s>(<#telems#>)|pla}
   | CETuple _ ->
      failwith "invalid tuple"
(** Used to print the elements of a tuple *)
and printChField (params:params) ((_name:string), (value:cexp)) =
   let tval = printExp params value in
   {pla|<#tval#>|pla}

(** Prints lhs values with and without declaration *)
and printLhsExp params (is_var:bool) (e:clhsexp) : Pla.t =
   match e with
   | CLId(typ, name) ->
      printTypeAndName is_var typ name
   (* if it was an '_' do not print anything *)
   | CLWild -> Pla.unit

   | CLIndex([CTSimple typ], [name], index) when is_var ->
      let index = printExp params index in
      {pla|<#typ#s> <#name#s>[<#index#>]|pla}

   | CLIndex(typ :: _, name, _) when is_var ->
      let name = dot name in
      let typ, sizes = simplifyArray typ in
      let sizes_t = Pla.map_join (fun i -> {pla|[<#i#s>]|pla}) sizes in
      {pla|<#typ#s> <#name#><#sizes_t#>|pla}

   | CLIndex([CTSimple _], [name], index) ->
      let index = printExp params index in
      {pla|<#name#s>[<#index#>]|pla}

   | _ -> failwith "uncovered case"

(** Used to print assignments on to an array element *)
let printArrayBinding params (var:string list) (i:int) (e:cexp) : Pla.t =
   let te = printExp params e in
   let var = dot var in
   {pla|<#var#>[<#i#i>] = <#te#>; |pla}

(** Prints arguments to functions either pass by value or reference *)
let printFunArg (ntype, name) : Pla.t =
   match ntype with
   | Var(typ) ->
      let tdescr = printTypeDescr typ in
      {pla|<#tdescr#> <#name#s>|pla}
   | Ref(CTArray(typ, _)) ->
      let tdescr = printTypeDescr typ in
      {pla|<#tdescr#> <#name#s>[]|pla}
   | Ref(typ) ->
      let tdescr = printTypeDescr typ in
      {pla|<#tdescr#> <#name#s>|pla}

(** Print a statement *)
let rec printStmt (params:params) (stmt:cstmt) : Pla.t option =
   match stmt with
   (* Strange case '_' *)
   | CSVar(CLWild, None) -> None

   (* Prints type x; *)

   | CSVar((CLId(tdescr, _) | CLIndex (tdescr, _, _)) as lhs, None) ->
      let tlhs = printLhsExp params true lhs in
      let init = getInitValue (List.hd tdescr) in
      Some({pla|<#tlhs#> = <#init#>; |pla})

   | CSVar(lhs, Some(value)) ->
      let value_t = printExp params value in
      let tlhs = printLhsExp params true lhs in
      Some({pla|<#tlhs#> = <#value_t#>; |pla})

   (* All other cases of assigning tuples will be wrong *)
   | CSVar(CLTuple(_), None) -> failwith "printStmt: invalid tuple assign"

   (* Prints _ = ... *)
   | CSBind(CLWild, value) ->
      let te = printExp params value in
      Some({pla|<#te#>;|pla})

   (* Print (x, y, z) = ... *)
   | CSBind(CLTuple(elems), CEVar(name, _)) ->
      let t = List.mapi (printLhsExpTuple name false) elems |> Pla.join in
      Some(t)

   (* All other cases of assigning tuples will be wrong *)
   | CSBind(CLTuple(_), _) -> failwith "printStmt: invalid tuple assign"

   (* Prints x = [ ... ] *)
   | CSBind(CLId(_, name), CEArray(elems, _)) ->
      let t = List.mapi (printArrayBinding params name) elems |> Pla.join in
      Some(t)

   (* Prints x = ... *)
   | CSBind(CLId(_, name), value) ->
      let te = printExp params value in
      let name = dot name in
      Some({pla|<#name#> = <#te#>;|pla})

   | CSBind(CLIndex(_, name, index), value) ->
      let te = printExp params value in
      let name = dot name in
      let index = printExp params index in
      Some({pla|<#name#>[<#index#>] = <#te#>;|pla})

   (* Prints const x = ... *)
   | CSConst(lhs, ((CEInt _ | CEFloat _ | CEBool _ | CEArray _ ) as value)) ->
      if params.is_header then
         let tlhs = printLhsExp params true lhs in
         let te = printExp params value in
         Some({pla|static final <#tlhs#> = <#te#>;|pla})
      else None

   (* All other cases should be errors *)
   | CSConst _ -> failwith "printStmt: invalid constant declaration"

   (* Function declarations cotaining more than one statement *)
   | CSFunction(ntype, name, args, (CSBlock(_) as body)) ->
      let ret   = printTypeDescr ntype in
      let targs = Pla.map_sep Pla.commaspace printFunArg args in
      (* if we are printing a header, skip the body *)
      if params.is_header then begin
         None
      end
      else begin
         match printStmt params body with
         | Some(tbody) ->
            Some({pla|<#ret#> <#name#s>(<#targs#>)<#tbody#><#>|pla})
         (* Covers the case when the body is empty *)
         | None -> Some({pla|<#ret#> <#name#s>(<#targs#>){}<#>|pla})
      end
   (* Function declarations cotaining a single statement *)
   | CSFunction(ntype, name, args, body) ->
      let ret = printTypeDescr ntype in
      let targs = Pla.map_sep Pla.commaspace printFunArg args in
      (* if we are printing a header, skip the body *)
      if params.is_header then
         None
      else
         let tbody = CCOpt.get_or ~default:Pla.unit (printStmt params body) in
         Some({pla|<#ret#> <#name#s>(<#targs#>){<#tbody#>}<#>|pla})

   (* Prints return x *)
   | CSReturn(e1) ->
      let te = printExp params e1 in
      Some({pla|return <#te#>;|pla})

   (* Printf while(cond) ... *)
   | CSWhile(cond, body) ->
      let tcond = printExp params cond in
      let tcond = if isSimple cond then Pla.parenthesize tcond else tcond in
      let tbody = CCOpt.get_or ~default:Pla.semi (printStmt params body) in
      Some({pla|while<#tcond#><#tbody#>|pla})

   (* Prints a block of statements*)
   | CSBlock(elems) ->
      let telems = printStmtList params elems in
      Some({pla|{<#telems#+>}|pla})

   (* If-statement without an else*)
   | CSIf(cond, then_, None) ->
      let tcond = printExp params cond in
      let tcond = if isSimple cond then Pla.wrap (Pla.string "(") (Pla.string ")") tcond else tcond in
      let tthen = CCOpt.get_or ~default:Pla.semi (wrapStmtIfNotBlock params then_) in
      Some({pla|if<#tcond#><#tthen#>|pla})

   (* If-statement with else*)
   | CSIf(cond, then_, Some(else_)) ->
      let tcond = printExp params cond in
      let tcond = if isSimple cond then Pla.wrap (Pla.string "(") (Pla.string ")") tcond else tcond in
      let tthen = CCOpt.get_or ~default:Pla.semi (wrapStmtIfNotBlock params then_) in
      let telse = CCOpt.get_or ~default:Pla.semi (wrapStmtIfNotBlock params else_) in
      Some({pla|if<#tcond#><#tthen#><#>else<#><#telse#>|pla})

   (* Type declaration (only in headers) *)
   | CSType(name, members) when params.is_header ->
      let tmembers =
         Pla.map_sep_all Pla.newline
            (fun (typ, name) ->
                let tmember = printTypeAndName true [typ] [name] in
                {pla|public <#tmember#>;|pla}
            ) members
      in
      let constructor =
         let args = Pla.map_sep Pla.comma (fun (typ, name) ->
               let tmember = printTypeAndName true [typ] [name] in
               {pla|<#tmember#>|pla}) members
         in
         let init = Pla.map_sep_all Pla.newline (fun (_, name) -> {pla|this.<#name#s> = <#name#s>;|pla}) members in
         {pla|<#name#s>(<#args#>){ <#init#> }|pla}
      in
      let constructor_default =
         let init =
            Pla.map_sep_all Pla.newline
               (fun (type_, name) ->
                   let value = getInitValue type_ in
                   {pla|this.<#name#s> = <#value#>;|pla}) members
         in
         {pla|<#name#s>(){ <#init#> }|pla}
      in
      Some({pla|class <#name#s> {<#tmembers#+> <#constructor_default#+> <#constructor#+> }<#>|pla})

   (* Do not print type delcarations in implementation file *)
   | CSType(_, _) -> None

   (* Type declaration aliases (only in headers) *)
   | CSAlias(_t1, _t2) when params.is_header ->
      (*let tdescr = printTypeDescr t2 in
        Some({pla|class <#tdescr#> extends <#t1#s>{}<#>|pla})*)
      None

   (* Do not print type delcarations in implementation file *)
   | CSAlias(_, _) -> None

   (* External function definitions (only in headers) *)
   | CSExtFunc(_ntype, _name, _args) when params.is_header ->
      (*let ret = printTypeDescr ntype in
        let targs = Pla.map_sep Pla.commaspace printFunArg args in
        Some({pla|extern <#ret#> <#name#s>(<#targs#>);|pla})*)
      None

   (* Do not print external function delcarations in implementation file *)
   | CSExtFunc _ -> None

   | CSEmpty -> None

and printStmtList (params:params) (stmts:cstmt list) : Pla.t =
   (* Prints the statements and removes all elements that are None *)
   let tstmts = CCList.filter_map (printStmt params) stmts in
   Pla.map_sep_all Pla.newline (fun a -> a) tstmts

and wrapStmtIfNotBlock params stmt =
   match stmt with
   | CSBlock _ -> printStmt params stmt
   | _ ->
      match printStmt params stmt with
      | Some(t) -> Some(Pla.wrap (Pla.string "{ ") (Pla.string " }") t)
      | _ -> None

(** Generates the .c and .h file contents for the given parsed files *)
let print (params:params) (stmts:Code.cstmt list) : (Pla.t * FileKind.t) list =
   let h   = printStmtList { params with is_header = true } stmts in
   let cpp = printStmtList { params with is_header = false } stmts in
   Templates.apply params params.module_name params.template (Pla.join [h; cpp])
