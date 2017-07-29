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

(** Template for the Teensy Audio library *)

open GenerateParams

(** Header function *)
let header (params:params) (code:Pla.t) : Pla.t =
   let file = String.uppercase_ascii params.output in
   {pla|
/* Code automatically generated by Vult https://github.com/modlfo/vult */
#ifndef <#file#s>_H
#define <#file#s>_H

#include <stdint.h>
#include <math.h>
#include "vultin.h"
#include "ext.h"
#include "ext_obex.h"
#include "z_dsp.h"

<#code#>

#if defined(_MSC_VER)
    //  Microsoft VC++
    #define EXPORT __declspec(dllexport)
#else
    //  GCC
    #define EXPORT __attribute__((visibility("default")))
#endif

extern "C" {
EXPORT void ext_main(void *r);
}

#endif // <#file#s>_H
|pla}

(** Add extra inlets if the object requires more than one *)
let addInlets (config:configuration) =
   let n = List.length config.process_inputs in
   let inlet_data =
      config.process_inputs
      |> List.mapi (fun i _ -> [ [%pla {|float in<#i#i>_value;|}]; [%pla {|short in<#i#i>_connected;|}]])
      |> List.flatten
      |> Pla.join_sep Pla.newline
      |> Pla.indent
   in
   let connected_inlets =
      config.process_inputs
      |> List.mapi (fun i _ -> [%pla {|x->in<#i#i>_connected = count[<#i#i>];|}])
      |> Pla.join_sep Pla.newline
      |> Pla.indent
   in
   let init = [%pla {|dsp_setup((t_pxobject *)x, <#n#i>);|}] in
   init, inlet_data, connected_inlets

(** Generates code to handle the float message in an inlet *)
let inletFloatMsg (config:configuration) =
   List.mapi
      (fun i _ -> [%pla {|if(in == <#i#i>) x->in<#i#i>_value = f;|}])
      config.process_inputs
   |> Pla.join_sep Pla.newline
   |> Pla.indent

let defaultInputs (config:configuration) =
   List.mapi
      (fun i _ -> [%pla {|float in_<#i#i>_value = x->in<#i#i>_connected? *(in_<#i#i>++): x->in<#i#i>_value;|}])
      config.process_inputs
   |> Pla.join_sep Pla.newline
   |> Pla.indent

(** Add the outlets *)
let addOutlets (config:configuration) =
   config.process_outputs
   |> List.map (fun _ -> Pla.string "outlet_new((t_object *)x, \"signal\");")
   |> Pla.join_sep Pla.newline
   |> Pla.indent

let castType (cast:string) (value:Pla.t) : Pla.t =
   match cast with
   | "float" -> [%pla{|(float) <#value#>|}]
   | "int" -> [%pla{|(int) <#value#>|}]
   | "bool" -> [%pla{|(bool) <#value#>|}]
   | _ ->[%pla{|<#cast#s>(<#value#>)|}]

let castInput (params:params) (typ:string) (value:Pla.t) : Pla.t =
   let current_typ = Replacements.getType params.repl typ in
   let cast = Replacements.getCast params.repl "float" current_typ in
   castType cast value

let castOutput (params:params) (typ:string) (value:Pla.t) : Pla.t =
   let current_typ = Replacements.getType params.repl typ in
   let cast = Replacements.getCast params.repl current_typ "float" in
   castType cast value

let tildePerformFunctionCall module_name (params:params) (config:configuration) =
   (* generates the aguments for the process call *)
   let args =
      List.mapi
         (fun i s ->
             castInput params s [%pla{|in_<#i#i>_value|}])
         config.process_inputs
      |> (fun a -> if config.pass_data then (Pla.string "x->data")::a else a)
      |> (fun a -> if List.length config.process_outputs > 1 then a@[Pla.string "ret"] else a)
      |> Pla.join_sep Pla.comma
   in
   (* declares the return variable and copies the values to the output buffers *)
   let ret,copy =
      let underscore = Pla.string "_" in
      match config.process_outputs with
      | []  -> Pla.unit,Pla.unit
      | [o] ->
         let current_typ = Replacements.getType params.repl o in
         let decl = [%pla{|<#current_typ#s> ret = |}] in
         let value = castOutput params o (Pla.string "ret") in
         let copy = [%pla{|*(out_0++) = <#value#>;|}] in
         decl,copy
      | o ->
         let decl = Pla.(string "_tuple_$_" ++ map_sep underscore string o ++ string "_$ ret; ") in
         let copy =
            List.mapi
               (fun i o ->
                   let value = castOutput params o [%pla{|ret.field_<#i#i>|}] in
                   [%pla{|*(out_<#i#i>++) = <#value#>;|}]) o
            |> Pla.join_sep_all Pla.newline
         in
         decl,copy
   in
   [%pla{|<#ret#> <#module_name#s>_process(<#args#>);<#><#copy#>|}]

(** Generates the buffer access of _tilde_perform function *)
let tildePerformFunctionVector (config:configuration) : Pla.t =
   let inputs = List.mapi (fun i _ -> [%pla{|double *in_<#i#i> = ins[<#i#i>];|}]) config.process_inputs in
   let outputs = List.mapi (fun i _ -> [%pla{|double *out_<#i#i> = outs[<#i#i>];|}]) config.process_outputs in
   let decl = inputs @ outputs |> Pla.join_sep Pla.newline |> Pla.indent in
   decl


let getInitDefaultCalls module_name params =
   if params.config.pass_data then
      [%pla{|<#module_name#s>_process_type|}],
      [%pla{|<#module_name#s>_process_init(x->data);|}],
      [%pla{|<#module_name#s>_default(x->data);|}]
   else
      Pla.string "float", Pla.unit, Pla.unit

let noteFunctions (params:params) =
   let output = params.output in
   let module_name = params.module_name in
   let on_args =
      ["(int)note"; "(int)velocity"; "(int)channel"]
      |> (fun a -> if params.config.pass_data then "x->data"::a else a)
      |> Pla.map_sep Pla.comma Pla.string
   in
   let off_args =
      ["(int)note"; "(int)channel"]
      |> (fun a -> if params.config.pass_data then "x->data"::a else a)
      |> Pla.map_sep Pla.comma Pla.string
   in
   [%pla{|
void <#output#s>_noteOn(t_<#output#s>_tilde *x, double note, double velocity, double channel){
   if((int)velocity) <#module_name#s>_noteOn(<#on_args#>);
   else <#module_name#s>_noteOff(<#off_args#>);
}
|}],
   [%pla{|
void <#output#s>_noteOff(t_<#output#s>_tilde *x, double note, double channel) {
   <#module_name#s>_noteOff(<#off_args#>);
}
|}]

let controlChangeFunction (params:params) =
   let output = params.output in
   let module_name = params.module_name in
   let ctrl_args =
      ["(int)control"; "(int)value"; "(int)channel"]
      |> (fun a -> if params.config.pass_data then "x->data"::a else a)
      |> Pla.map_sep Pla.comma Pla.string
   in
   [%pla{|
void <#output#s>_controlChange(t_<#output#s>_tilde *x, double control, double value, double channel) {
   <#module_name#s>_controlChange(<#ctrl_args#>);
}
|}]

(** Implementation function *)
let implementation (params:params) (code:Pla.t) : Pla.t =
   let output = params.output in
   let module_name = params.module_name in
   (* Generate extra inlets *)
   let inlets, inlet_data, connected_inlets = addInlets params.config in
   (* Generates the outlets*)
   let outlets = addOutlets params.config in

   let inlet_float_msg = inletFloatMsg params.config in
   let default_inputs = defaultInputs params.config in

   let io_decl = tildePerformFunctionVector params.config in
   let process_call = tildePerformFunctionCall module_name params params.config in
   let main_type, init_call, default_call = getInitDefaultCalls module_name params in
   let note_on, note_off = noteFunctions params in
   let ctr_change = controlChangeFunction params in
   {pla|
/* Code automatically generated by Vult https://github.com/modlfo/vult */
#include "<#output#s>.h"

<#code#>

extern "C" {

static t_class *<#output#s>_tilde_class;

typedef struct _<#output#s>_tilde {
   t_pxobject  x_obj;
   float dummy;
   <#inlet_data#>
   <#main_type#> data;
} t_<#output#s>_tilde;

void <#output#s>_tilde_perform(t_<#output#s>_tilde *x, t_object *dsp64, double **ins, long numins, double **outs, long numouts, long sampleframes, long flags, void *userparam)
{
<#io_decl#>

   int n = sampleframes;
   while (n--) {
      <#default_inputs#>
      <#process_call#+>
   }
}

void <#output#s>_tilde_dsp(t_<#output#s>_tilde *x, t_object *dsp64, short *count, double samplerate, long maxvectorsize, long flags)
{
   <#connected_inlets#>
   object_method(dsp64, gensym("dsp_add64"), x, <#output#s>_tilde_perform, 0, NULL);
}

void *<#output#s>_tilde_new(t_symbol *s, long argc, t_atom *argv)
{
   t_<#output#s>_tilde *x = (t_<#output#s>_tilde *)object_alloc(<#output#s>_tilde_class);

   <#init_call#>
   <#default_call#>
<#inlets#>
<#outlets#>

   return (void *)x;
}

void <#output#s>_tilde_delete(t_<#output#s>_tilde *x){

}

<#note_on#>
<#note_off#>
<#ctr_change#>

void <#output#s>_float(t_<#output#s>_tilde *x, double f){
   int in = proxy_getinlet((t_object *)x);
   <#inlet_float_msg#>
}

void ext_main(void *r) {
   <#output#s>_tilde_class = class_new("<#output#s>~",
      (method)<#output#s>_tilde_new, // constructor function
      (method)<#output#s>_tilde_delete, // destructor function
      (long)sizeof(t_<#output#s>_tilde), // size of the object
       0L, A_GIMME, 0); // arguments passed

   class_addmethod(<#output#s>_tilde_class,(method)<#output#s>_tilde_dsp, "dsp64", A_CANT, 0);

   class_addmethod(<#output#s>_tilde_class, (method)<#output#s>_noteOn,        "noteOn",        A_DEFFLOAT, A_DEFFLOAT, A_DEFFLOAT, 0);
   class_addmethod(<#output#s>_tilde_class, (method)<#output#s>_noteOff,       "noteOff",       A_DEFFLOAT, A_DEFFLOAT, 0);
   class_addmethod(<#output#s>_tilde_class, (method)<#output#s>_controlChange, "controlChange", A_DEFFLOAT, A_DEFFLOAT, A_DEFFLOAT, 0);
   class_addmethod(<#output#s>_tilde_class, (method)<#output#s>_float, "float", A_FLOAT, 0);

   class_dspinit(<#output#s>_tilde_class);
   class_register(CLASS_BOX, <#output#s>_tilde_class);
}

} // extern "C"
|pla}

let get (params:params) (header_code:Pla.t) (impl_code:Pla.t) : (Pla.t * filename) list =
   [
      header params header_code, ExtOnly "h";
      implementation params impl_code, ExtOnly "cpp"
   ]