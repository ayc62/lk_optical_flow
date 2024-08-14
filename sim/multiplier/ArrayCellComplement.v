`ifndef ARRAY_CELL_COMPLEMENT_V
`define ARRAY_CELL_COMPLEMENT_V

`include "vc/arithmetic.v"

module multiplier_ArrayCellComplement
(
input  logic        clk,
input  logic        reset,

input logic s_in,
input logic a,
input logic c_in,
input logic b,
output logic c_out,
output logic s_out

);

vc_Adder
#(1) array_cell (
  .in0(~(a&b)),
  .in1(s_in),
  .cin(c_in),
  .out(s_out),
  .cout(c_out)
);

endmodule


`endif
