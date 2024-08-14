`ifndef FINAL_ROW_CELL_V
`define FINAL_ROW_CELL_V

`include "vc/arithmetic.v"

module multiplier_FinalRowCell
(
input  logic        clk,
input  logic        reset,

input logic a,
input logic c_in,
input logic b,
output logic c_out,
output logic s_out

);

vc_Adder
#(1) array_cell (
  .in0(a),
  .in1(b),
  .cin(c_in),
  .out(s_out),
  .cout(c_out)
);

endmodule


`endif
