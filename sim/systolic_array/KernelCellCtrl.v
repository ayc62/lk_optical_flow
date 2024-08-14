//========================================================================
// Kernel Cell Ctrl
//========================================================================

`ifndef KERNEL_CELL_CTRL_V
`define KERNEL_CELL_CTRL_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/arithmetic.v"
`include "systolic_array/PE.v"


module systolic_array_KernelCellCtrl 
(
    input  logic        clk,
    input  logic        reset,

    input logic x1_val,
    input logic x2_val,
    input logic x3_val,
    input logic new_row,

    output logic result_val
);

logic val_1_reg [4:0];
logic val_2_reg [4:0];
logic val_3_reg [4:0];
logic new_row_reg [3:0];

always @(posedge clk) begin
    for (int n = 1; n < 5; n = n + 1) begin
        val_1_reg[n] <= val_1_reg[n-1];
        val_2_reg[n] <= val_2_reg[n-1];
        val_3_reg[n] <= val_3_reg[n-1];
    end
    for (int n = 1; n < 4; n = n + 1) begin
        new_row_reg[n] <= new_row_reg[n-1];
    end
    val_1_reg[0] <= x1_val;
    val_2_reg[0] <= x2_val;
    val_3_reg[0] <= x3_val;
    new_row_reg[0] <= new_row;
end

assign result_val = val_1_reg[4] && val_1_reg[3] && val_1_reg[2] &&
                    val_2_reg[4] && val_2_reg[3] && val_2_reg[2] &&
                    val_3_reg[4] && val_3_reg[3] && val_3_reg[2] && 
                    !new_row_reg[2] && !new_row_reg[3];


endmodule

`endif
