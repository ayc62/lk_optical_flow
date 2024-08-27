//========================================================================
// Register Array Implementation
//========================================================================

`ifndef KERNEL_CELL_X_WRAPPER_V
`define KERNEL_CELL_X_WRAPPER_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "systolic_array/KernelCellX.v"


module systolic_array_KernelCellXWrapper
(
    input  logic        clk,
    input  logic        reset,

    input  logic [8-1:0] x1,
    input logic x1_val,
    input logic [8-1:0] x2,
    input logic x2_val,
    input logic [8-1:0] x3,
    input logic x3_val,

    output  logic [8:0] result,
    output logic result_val,
    input logic new_row

);

localparam data_width = 8;

logic [data_width:0] result_reg_in;
logic result_val_reg_in;

systolic_array_KernelCellX #(data_width) kernel_cell (
    .clk(clk),
    .reset(reset),
    .x1(x1),
    .x1_val(x1_val),
    .x2(x2),
    .x2_val(x2_val),
    .x3(x3),
    .x3_val(x3_val),

    .result(result_reg_in),
    .result_val(result_val_reg_in),
    .new_row(new_row)
);

vc_ResetReg #(data_width+1) result_reg (
    .clk(clk),
    .reset(reset),
    .d(result_reg_in),
    .q(result)
);

vc_ResetReg #(1) result_val_reg (
    .clk(clk),
    .reset(reset),
    .d(result_val_reg_in),
    .q(result_val)
);


//----------------------------------------------------------------------
// Input Registers (sequential logic)
//----------------------------------------------------------------------


`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
`VC_TRACE_BEGIN
begin

end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule

`endif /* REG_ARRAY_V */
