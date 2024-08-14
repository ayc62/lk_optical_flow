`ifndef ZERO_PE_V
`define ZERO_PE_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/arithmetic.v"

module systolic_array_ZeroPE #(
    parameter data_width = 32
)
(
input  logic        clk,
input  logic        reset,

input  logic [data_width-1:0] x_in,
input logic [data_width-1:0] y_in,

output  logic [data_width-1:0] x_out,
output logic [data_width-1:0] y_out

);

logic [data_width-1:0] x;

vc_ResetReg#(data_width) x_reg (
    .clk(clk),
    .reset(reset),
    .d(x_in),
    .q(x)
);

vc_ResetReg#(data_width) x_out_reg (
    .clk(clk),
    .reset(reset),
    .d(x),
    .q(x_out)
);

vc_ResetReg#(data_width) y_out_reg (
    .clk(clk),
    .reset(reset),
    .d(y_in),
    .q(y_out)
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

`endif