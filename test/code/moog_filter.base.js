function vultProcess(){
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
    this.process_init = null;
    this.default_ = null;


this._ctx_type_0_init = function(){
   var _ctx = {};
   _ctx.pre_x = 0.;
   return _ctx;
}
this. change_init = function() { return this._ctx_type_0_init();}
this.change = function(_ctx,x){
   var v = (_ctx.pre_x != x);
   _ctx.pre_x = x;
   return v;
}
this.min = function(a,b){
   return ((a < b)?a:b);
}
this.max = function(a,b){
   return ((a > b)?a:b);
}
this.clip = function(value,low,high){
   return this.min(this.max(low,value),high);
}
this.samplerate = function(){
   return 44100.;
}
this.PI = function(){
   return 3.14159265359;
}
this.thermal = function(){
   return (1. / 1.22070313);
}


this._ctx_type_7_init = function(){
   var _ctx = {};
   _ctx.tw2 = 0.;
   _ctx.tw1 = 0.;
   _ctx.tw0 = 0.;
   _ctx.dw3 = 0.;
   _ctx.dw2 = 0.;
   _ctx.dw1 = 0.;
   _ctx.dw0 = 0.;
   return _ctx;
}
this. moog_step_init = function() { return this._ctx_type_7_init();}
this.moog_step = function(_ctx,input,resFixed,tune,output){
   var i0 = (input - (resFixed * output));
   var w0 = (_ctx.dw0 + (tune * (this.tanh((i0 * this.thermal())) - _ctx.tw0)));
   _ctx.tw0 = this.tanh((w0 * this.thermal()));
   var w1 = ((_ctx.dw1 + (tune * _ctx.tw0)) - _ctx.tw1);
   _ctx.tw1 = this.tanh((w1 * this.thermal()));
   var w2 = ((_ctx.dw2 + (tune * _ctx.tw1)) - _ctx.tw2);
   _ctx.tw2 = this.tanh((w2 * this.thermal()));
   var w3 = ((_ctx.dw3 + (tune * _ctx.tw2)) - this.tanh((_ctx.dw3 * this.thermal())));
   _ctx.dw0 = w0;
   _ctx.dw1 = w1;
   _ctx.dw2 = w2;
   _ctx.dw3 = w3;
   return w3;
}


this._ctx_type_8_init = function(){
   var _ctx = {};
   _ctx.tune = 0.;
   _ctx.resFixed = 0.;
   _ctx.filter = this._ctx_type_7_init();
   _ctx.dx1 = 0.;
   _ctx._inst1 = this._ctx_type_0_init();
   _ctx._inst0 = this._ctx_type_0_init();
   return _ctx;
}
this. moog_init = function() { return this._ctx_type_8_init();}
this.moog = function(_ctx,input,cut,res){
   if((this.change(_ctx._inst0,cut) || this.change(_ctx._inst1,res))){
      res = this.clip(res,0.,1.);
      cut = this.clip(cut,1.,this.samplerate());
      var fc = (cut / this.samplerate());
      var x_2 = (fc / 2.);
      var x2 = (fc * fc);
      var x3 = (fc * x2);
      var fcr = ((((1.873 * x3) + (0.4955 * x2)) - (0.649 * fc)) + 0.9988);
      var acr = ((((- 3.9364) * x2) + (1.8409 * fc)) + 0.9968);
      _ctx.tune = ((1. - this.exp((- (((2. * this.PI()) * x_2) * fcr)))) / this.thermal());
      _ctx.resFixed = ((4. * res) * acr);
   }
   var x0 = this.moog_step(_ctx.filter,input,_ctx.resFixed,_ctx.tune,_ctx.dx1);
   var x1 = this.moog_step(_ctx.filter,input,_ctx.resFixed,_ctx.tune,x0);
   _ctx.dx1 = x1;
   return ((x0 + x1) / 2.);
}
var n = ((0|0)|0);
while((n < (44100|0))){
   var kk = this.moog(_ctx.x,1.,2000.,0.1);
   n = ((n + (1|0))|0);
}
return (0|0);

    if(this.process_init)  this.context =  this.process_init(); else this.context = {};
    if(this.default_)      this.default_(this.context);
    this.liveNoteOn        = function(note,velocity) { if(this.noteOn)        this.noteOn(this.context,note,velocity); };
    this.liveNoteOff       = function(note,velocity) { if(this.noteOff)       this.noteOff(this.context,note,velocity); };
    this.liveControlChange = function(note,velocity) { if(this.controlChange) this.controlChange(this.context,note,velocity); };
    this.liveProcess       = function(input)         { if(this.process)       return this.process(this.context,input); else return 0; };
    this.liveDefault       = function()              { if(this.default_)      return this.default_(this.context); };
}