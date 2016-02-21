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


this._ctx_type_2_init = function(){
   var _ctx = {};
   _ctx.pre_x = ((0|0)|0);
   return _ctx;
}
this. edge_init = function() { return this._ctx_type_2_init();}
this.edge = function(_ctx,x){
   var v = ((_ctx.pre_x != x) && (_ctx.pre_x == (0|0)));
   _ctx.pre_x = (x|0);
   return v;
}


this._ctx_type_3_init = function(){
   var _ctx = {};
   _ctx.count = ((0|0)|0);
   return _ctx;
}
this. each_init = function() { return this._ctx_type_3_init();}
this.each = function(_ctx,n){
   var ret = (_ctx.count == (0|0));
   _ctx.count = (((_ctx.count + (1|0)) % n)|0);
   return ret;
}
this.pitchToRate = function(d){
   return ((8.1758 * this.exp((0.0577623 * d))) / 44100.);
}


this._ctx_type_5_init = function(){
   var _ctx = {};
   _ctx.rate = 0.;
   _ctx.phase = 0.;
   _ctx._inst0 = this._ctx_type_1_init();
   return _ctx;
}
this. phasor_init = function() { return this._ctx_type_5_init();}
this.phasor = function(_ctx,pitch,reset){
   if(this.change(_ctx._inst0,pitch)){
      _ctx.rate = this.pitchToRate(pitch);
   }
   _ctx.phase = (reset?0.:((_ctx.phase + _ctx.rate) % 1.));
   return _ctx.phase;
}


this._ctx_type_6_init = function(){
   var _ctx = {};
   _ctx.phase = 0.;
   _ctx._inst0 = this._ctx_type_2_init();
   return _ctx;
}
this. lfo_init = function() { return this._ctx_type_6_init();}
this.lfo = function(_ctx,f,gate){
   var rate = ((f * 10.) / 44100.);
   if(this.edge(_ctx._inst0,gate)){
      _ctx.phase = 0.;
   }
   _ctx.phase = (_ctx.phase + rate);
   if((_ctx.phase > 1.)){
      _ctx.phase = (_ctx.phase - 1.);
   }
   return (this.sin(((_ctx.phase * 2.) * 3.14159265359)) - 0.5);
}


this._ctx_type_7_init = function(){
   var _ctx = {};
   _ctx.volume = 0.;
   _ctx.pre_phase1 = 0.;
   _ctx.pitch = 0.;
   _ctx.n4 = 0.;
   _ctx.n3 = 0.;
   _ctx.n2 = 0.;
   _ctx.n1 = 0.;
   _ctx.lfo_rate = 0.;
   _ctx.lfo_amt = 0.;
   _ctx.gate = ((0|0)|0);
   _ctx.detune = 0.;
   _ctx.count = ((0|0)|0);
   _ctx._inst5 = this._ctx_type_0_init();
   _ctx._inst4 = this._ctx_type_0_init();
   _ctx._inst3 = this._ctx_type_5_init();
   _ctx._inst2 = this._ctx_type_0_init();
   _ctx._inst1 = this._ctx_type_5_init();
   _ctx._inst0 = this._ctx_type_6_init();
   return _ctx;
}
this. process_init = function() { return this._ctx_type_7_init();}
this.process = function(_ctx,input){
   var lfo_val = (this.lfo(_ctx._inst0,_ctx.lfo_rate,_ctx.gate) * _ctx.lfo_amt);
   var phase1 = this.phasor(_ctx._inst1,_ctx.pitch,false);
   var comp = (1. - phase1);
   var reset = ((_ctx.pre_phase1 - phase1) > 0.5);
   _ctx.pre_phase1 = phase1;
   var phase2 = this.phasor(_ctx._inst3,(_ctx.pitch + (this.smooth(_ctx._inst2,(_ctx.detune + lfo_val)) * 32.)),reset);
   var sine = this.sin(((2. * 3.14159265359) * phase2));
   var gate_value = ((_ctx.gate > (0|0))?1.:0.);
   return ((this.smooth(_ctx._inst4,_ctx.volume) * (sine * comp)) * this.smooth(_ctx._inst5,gate_value));
}

this. noteOn_init = function() { return this._ctx_type_7_init();}
this.noteOn = function(_ctx,note,velocity){
   if((_ctx.count == (0|0))){
      _ctx.n1 = note;
      _ctx.pitch = note;
   }
   else
   {
      if((_ctx.count == (1|0))){
         _ctx.n2 = note;
         _ctx.pitch = note;
      }
      else
      {
         if((_ctx.count == (2|0))){
            _ctx.n3 = note;
            _ctx.pitch = note;
         }
         else
         {
            if((_ctx.count == (3|0))){
               _ctx.n4 = note;
               _ctx.pitch = note;
            }
         }
      }
   }
   if((_ctx.count <= (4|0))){
      _ctx.count = ((_ctx.count + (1|0))|0);
   }
   _ctx.gate = (((_ctx.count > (0|0))?(1|0):(0|0))|0);
}

this. noteOff_init = function() { return this._ctx_type_7_init();}
this.noteOff = function(_ctx,note){
   var found = false;
   if((note == _ctx.n1)){
      var _tmp_0 = _ctx.n2;
      var _tmp_1 = _ctx.n3;
      var _tmp_2 = _ctx.n4;
      _ctx.n1 = _tmp_0;
      _ctx.n2 = _tmp_1;
      _ctx.n3 = _tmp_2;
      found = true;
   }
   else
   {
      if((note == _ctx.n2)){
         var _tmp_0 = _ctx.n3;
         var _tmp_1 = _ctx.n4;
         _ctx.n2 = _tmp_0;
         _ctx.n3 = _tmp_1;
         found = true;
      }
      else
      {
         if((note == _ctx.n3)){
            _ctx.n3 = _ctx.n4;
            found = true;
         }
         else
         {
            if((note == _ctx.n4)){
               found = true;
            }
         }
      }
   }
   if((found && (_ctx.count > (0|0)))){
      _ctx.count = ((_ctx.count - (1|0))|0);
   }
   _ctx.gate = (((_ctx.count > (0|0))?(1|0):(0|0))|0);
   if((_ctx.count == (1|0))){
      _ctx.pitch = _ctx.n1;
   }
   if((_ctx.count == (2|0))){
      _ctx.pitch = _ctx.n2;
   }
   if((_ctx.count == (3|0))){
      _ctx.pitch = _ctx.n3;
   }
   if((_ctx.count == (4|0))){
      _ctx.pitch = _ctx.n4;
   }
}

this. controlChange_init = function() { return this._ctx_type_7_init();}
this.controlChange = function(_ctx,control,value){
   if((control == (30|0))){
      _ctx.volume = (value / 127.);
   }
   if((control == (31|0))){
      _ctx.detune = (value / 127.);
   }
   if((control == (32|0))){
      _ctx.lfo_rate = (value / 127.);
   }
   if((control == (33|0))){
      _ctx.lfo_amt = (2. * ((this.real(value) / 127.) - 0.5));
   }
}

this. default_init = function() { return this._ctx_type_7_init();}
this.default_ = function(_ctx){
   _ctx.volume = 0.;
   _ctx.pitch = 45.;
   _ctx.detune = 0.8;
   _ctx.lfo_rate = 0.07;
   _ctx.lfo_amt = (- 0.8);
}

    if(this.process_init)  this.context =  this.process_init(); else this.context = {};
    if(this.default_)      this.default_(this.context);
    this.liveNoteOn        = function(note,velocity) { if(this.noteOn)        this.noteOn(this.context,note,velocity); };
    this.liveNoteOff       = function(note,velocity) { if(this.noteOff)       this.noteOff(this.context,note,velocity); };
    this.liveControlChange = function(note,velocity) { if(this.controlChange) this.controlChange(this.context,note,velocity); };
    this.liveProcess       = function(input)         { if(this.process)       return this.process(this.context,input); else return 0; };
    this.liveDefault       = function()              { if(this.default_)      return this.default_(this.context); };
}