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
   _ctx.pre = ((0|0)|0);
   _ctx.n4 = ((0|0)|0);
   _ctx.n3 = ((0|0)|0);
   _ctx.n2 = ((0|0)|0);
   _ctx.n1 = ((0|0)|0);
   _ctx.count = ((0|0)|0);
   return _ctx;
}
this. noteOn_init = function() { return this._ctx_type_0_init();}
this.noteOn = function(_ctx,n){
   if((_ctx.count == (0|0))){
      _ctx.n1 = (n|0);
      _ctx.pre = (n|0);
   }
   else
   {
      if((_ctx.count == (1|0))){
         _ctx.n2 = (n|0);
         _ctx.pre = (n|0);
      }
      else
      {
         if((_ctx.count == (2|0))){
            _ctx.n3 = (n|0);
            _ctx.pre = (n|0);
         }
         else
         {
            if((_ctx.count == (3|0))){
               _ctx.n4 = (n|0);
               _ctx.pre = (n|0);
            }
         }
      }
   }
   if((_ctx.count <= (4|0))){
      _ctx.count = ((_ctx.count + (1|0))|0);
   }
   return _ctx.pre;
}

this. noteOff_init = function() { return this._ctx_type_0_init();}
this.noteOff = function(_ctx,n){
   var found = false;
   if((n == _ctx.n1)){
      var _tmp_0 = (_ctx.n2|0);
      var _tmp_1 = (_ctx.n3|0);
      var _tmp_2 = (_ctx.n4|0);
      _ctx.n1 = (_tmp_0|0);
      _ctx.n2 = (_tmp_1|0);
      _ctx.n3 = (_tmp_2|0);
      found = true;
   }
   else
   {
      if((n == _ctx.n2)){
         var _tmp_0 = (_ctx.n3|0);
         var _tmp_1 = (_ctx.n4|0);
         _ctx.n2 = (_tmp_0|0);
         _ctx.n3 = (_tmp_1|0);
         found = true;
      }
      else
      {
         if((n == _ctx.n3)){
            _ctx.n3 = (_ctx.n4|0);
            found = true;
         }
         else
         {
            if((n == _ctx.n4)){
               found = true;
            }
         }
      }
   }
   if((found && (_ctx.count > (0|0)))){
      _ctx.count = ((_ctx.count - (1|0))|0);
   }
   if((_ctx.count == (1|0))){
      _ctx.pre = (_ctx.n1|0);
   }
   if((_ctx.count == (2|0))){
      _ctx.pre = (_ctx.n2|0);
   }
   if((_ctx.count == (3|0))){
      _ctx.pre = (_ctx.n3|0);
   }
   if((_ctx.count == (4|0))){
      _ctx.pre = (_ctx.n4|0);
   }
   return _ctx.pre;
}

this. isGateOn_init = function() { return this._ctx_type_0_init();}
this.isGateOn = function(_ctx){
   return (_ctx.count > (0|0));
}

    if(this.process_init)  this.context =  this.process_init(); else this.context = {};
    if(this.default_)      this.default_(this.context);
    this.liveNoteOn        = function(note,velocity) { if(this.noteOn)        this.noteOn(this.context,note,velocity); };
    this.liveNoteOff       = function(note,velocity) { if(this.noteOff)       this.noteOff(this.context,note,velocity); };
    this.liveControlChange = function(note,velocity) { if(this.controlChange) this.controlChange(this.context,note,velocity); };
    this.liveProcess       = function(input)         { if(this.process)       return this.process(this.context,input); else return 0; };
    this.liveDefault       = function()              { if(this.default_)      return this.default_(this.context); };
}