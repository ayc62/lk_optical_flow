//========================================================================
// Register Array Implementation
//========================================================================

`ifndef PE_V
`define PE_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/arithmetic.v"

module systolic_array_PE
#(
    parameter data_width = 32,
    parameter p_shamt_nbits = 3
)(
input  logic        clk,
input  logic        reset,

input  logic [data_width-1:0] x_in,
input logic [data_width-1:0] y_in,

output  logic [data_width-1:0] x_out,
output logic [data_width-1:0] y_out,

input logic [p_shamt_nbits-1:0] shamt1,
input logic [p_shamt_nbits-1:0] shamt2

);

logic [data_width-1:0] x;

vc_ResetReg#(data_width) x_reg (
    .clk(clk),
    .d(x_in),
    .q(x),
    .reset(reset)
);

vc_ResetReg#(data_width) x_out_reg (
    .clk(clk),
    .d(x),
    .q(x_out),
    .reset(reset)
);

logic [data_width-1:0] x_shift1;
vc_LeftLogicalShifter#(data_width, p_shamt_nbits) x_shifter1 (
    .in(x_in),
    .shamt(shamt1),
    .out(x_shift1)
);

logic [data_width-1:0] x_shift2;
vc_LeftLogicalShifter#(data_width, p_shamt_nbits) x_shifter2 (
    .in(x_in),
    .shamt(shamt2),
    .out(x_shift2)
);

logic [data_width-1:0] x_shift_add;
vc_SimpleAdder#(data_width) x_shift_adder (
    .in0(x_shift1),
    .in1(x_shift2),
    .out(x_shift_add)
);

logic [data_width-1:0] y_out_result;
vc_SimpleAdder#(data_width) y_out_adder (
    .in0(x_shift_add),
    .in1(y_in),
    .out(y_out_result)
);

vc_ResetReg#(data_width) y_out_reg (
    .clk(clk),
    .d(y_out_result),
    .q(y_out),
    .reset(reset)
);

`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
`VC_TRACE_BEGIN
begin
    $sformat( str, "%x", x);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "|" );

end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule

`endif /* REG_ARRAY_V */
