`ifndef SIMPLE_MULT_V
`define SIMPLE_MULT_V

`include "vc/regs.v"
`include "vc/arithmetic.v"
`include "vc/trace.v"

module multiplier_SimpleMultWrapper
#(
    parameter x_width = 4,
    parameter y_width = 6,
    // assume y_width > x_width

    parameter p_width = x_width + y_width,
    parameter num_rows = x_width + 1,
    parameter num_cols = y_width
)(
input  logic        clk,
input  logic        reset,

input  logic        y_val,
input  logic        x_val,
input logic [y_width-1:0] y,
input logic [x_width-1:0] x,

output logic [p_width-1:0] p,
output logic        p_val
);

logic x_val_reg_out;
vc_ResetReg#(1) x_val_reg (
  .d(x_val),
  .q(x_val_reg_out),
  .*
);

logic y_val_reg_out;
vc_ResetReg#(1) y_val_reg (
  .d(y_val),
  .q(y_val_reg_out),
  .*
);

logic [x_width-1:0] x_reg_out;
vc_ResetReg#(x_width) x_reg (
  .d(x),
  .q(x_reg_out),
  .*
);

logic [y_width-1:0] y_reg_out;
vc_ResetReg#(y_width) y_reg (
  .d(y),
  .q(y_reg_out),
  .*
);

logic [p_width-1:0] p_reg_in;
vc_ResetReg#(p_width) p_reg (
  .d(p_reg_in),
  .q(p),
  .*
);

logic p_val_reg_in;
vc_ResetReg#(1) p_val_reg (
  .d(p_val_reg_in),
  .q(p_val),
  .*
);

assign p_val_reg_in = x_val_reg_out && y_val_reg_out;

multiplier_SimpleMultDPath
#(
    x_width,
    y_width
) simple_mult (

.x(x_reg_out),
.y(y_reg_out),

.p(p_reg_in)
);


endmodule

module multiplier_SimpleMult
#(
    parameter x_width = 4,
    parameter y_width = 6,
    // assume y_width > x_width

    parameter p_width = x_width + y_width,
    parameter num_rows = x_width + 1,
    parameter num_cols = y_width
)(

input logic [y_width-1:0] y,
input logic [x_width-1:0] x,

output logic [p_width-1:0] p
);

logic [p_width-1:0] y_sext;
vc_SignExtender#(y_width, p_width) y_reg_out_sign_extender
(
    .in(y),
    .out(y_sext)
);

logic [p_width-1:0] x_sext;
vc_SignExtender#(x_width, p_width) x_reg_out_sign_extender
(
    .in(x),
    .out(x_sext)
);

assign p = (x_sext) * (y_sext);


endmodule

`endif
