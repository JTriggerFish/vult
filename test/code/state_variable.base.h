#ifndef STATE_VARIABLE_H
#define STATE_VARIABLE_H
#include <stdint.h>
#include <math.h>

typedef struct _ctx_type_0 {
   float pre_x;
} _ctx_type_0;

typedef _ctx_type_0 change_type;

_ctx_type_0 _ctx_type_0_init();

_ctx_type_0 change_init();

uint8_t change(_ctx_type_0 &_ctx, float x);

typedef struct _ctx_type_1 {
   float dlow;
   float dband;
} _ctx_type_1;

typedef _ctx_type_1 svf_step_type;

_ctx_type_1 _ctx_type_1_init();

_ctx_type_1 svf_step_init();

float svf_step(_ctx_type_1 &_ctx, float input, float g, float q, int sel);

typedef struct _ctx_type_2 {
   _ctx_type_1 step;
   float g;
   _ctx_type_0 _inst0;
} _ctx_type_2;

typedef _ctx_type_2 svf_type;

_ctx_type_2 _ctx_type_2_init();

_ctx_type_2 svf_init();

float svf(_ctx_type_2 &_ctx, float input, float fc, float q, int sel);



#endif // STATE_VARIABLE_H