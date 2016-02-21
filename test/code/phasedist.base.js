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
   _ctx.x = 0.;
   return _ctx;
}
this. smooth_init = function() { return this._ctx_type_0_init();}
this.smooth = function(_ctx,input){
   _ctx.x = (_ctx.x + ((input - _ctx.x) * 0.005));
   return _ctx.x;
}


this._ctx_type_1_init = function(){
   var _ctx = {};
   _ctx.pre_x = 0.;
   return _ctx;
}
this. change_init = function() { return this._ctx_type_1_init();}
this.change = function(_ctx,x){
   var v = (_ctx.pre_x != x);
   _ctx.pre_x = x;
   return v;
}
this.pitchToRate = function(d){
   return ((8.1758 * this.exp((0.0577623 * d))) / 44100.);
}


this._ctx_type_3_init = function(){
   var _ctx = {};
   _ctx.rate = 0.;
   _ctx.phase = 0.;
   _ctx._inst0 = this._ctx_type_1_init();
   return _ctx;
}
this. phasor_init = function() { return this._ctx_type_3_init();}
this.phasor = function(_ctx,pitch,reset){
   if(this.change(_ctx._inst0,pitch)){
      _ctx.rate = this.pitchToRate(pitch);
   }
   _ctx.phase = (reset?0.:((_ctx.phase + _ctx.rate) % 1.));
   return _ctx.phase;
}


this._ctx_type_4_init = function(){
   var _ctx = {};
   _ctx.volume = 0.;
   _ctx.pre_phase1 = 0.;
   _ctx.pitch = 0.;
   _ctx.detune = 0.;
   _ctx._inst3 = this._ctx_type_0_init();
   _ctx._inst2 = this._ctx_type_3_init();
   _ctx._inst1 = this._ctx_type_0_init();
   _ctx._inst0 = this._ctx_type_3_init();
   return _ctx;
}
this. process_init = function() { return this._ctx_type_4_init();}
this.process = function(_ctx,input){
   var phase1 = this.phasor(_ctx._inst0,_ctx.pitch,false);
   var comp = (1. - phase1);
   var reset = ((_ctx.pre_phase1 - phase1) > 0.5);
   _ctx.pre_phase1 = phase1;
   var phase2 = this.phasor(_ctx._inst2,(_ctx.pitch + (this.smooth(_ctx._inst1,_ctx.detune) * 32.)),reset);
   var sine = this.sin(((2. * 3.14159265359) * phase2));
   return (this.smooth(_ctx._inst3,_ctx.volume) * (sine * comp));
}

this. noteOn_init = function() { return this._ctx_type_4_init();}
this.noteOn = function(_ctx,note,velocity){
   _ctx.pitch = this.real(note);
}

this. noteOff_init = function() { return this._ctx_type_4_init();}
this.noteOff = function(_ctx,note){
}

this. controlChange_init = function() { return this._ctx_type_4_init();}
this.controlChange = function(_ctx,control,value){
   if((control == (30|0))){
      _ctx.volume = (this.real(value) / 127.);
   }
   if((control == (31|0))){
      _ctx.detune = (this.real(value) / 127.);
   }
}

this. default_init = function() { return this._ctx_type_4_init();}
this.default_ = function(_ctx){
   _ctx.volume = 0.;
   _ctx.pitch = 45.;
   _ctx.detune = 0.;
}

    if(this.process_init)  this.context =  this.process_init(); else this.context = {};
    if(this.default_)      this.default_(this.context);
    this.liveNoteOn        = function(note,velocity) { if(this.noteOn)        this.noteOn(this.context,note,velocity); };
    this.liveNoteOff       = function(note,velocity) { if(this.noteOff)       this.noteOff(this.context,note,velocity); };
    this.liveControlChange = function(note,velocity) { if(this.controlChange) this.controlChange(this.context,note,velocity); };
    this.liveProcess       = function(input)         { if(this.process)       return this.process(this.context,input); else return 0; };
    this.liveDefault       = function()              { if(this.default_)      return this.default_(this.context); };
}