//========================================================================
// Register Array Implementation
//========================================================================

`ifndef KERNEL_CELL_X_V
`define KERNEL_CELL_X_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/arithmetic.v"
`include "systolic_array/PE.v"
`include "systolic_array/NegPE.v"
`include "systolic_array/ZeroPE.v"
`include "systolic_array/KernelCellCtrl.v"


module systolic_array_KernelCellX #(
    parameter data_width = 8
)
(
    input  logic        clk,
    input  logic        reset,

    input  logic [data_width-1:0] x1,
    input logic x1_val,
    input logic [data_width-1:0] x2,
    input logic x2_val,
    input logic [data_width-1:0] x3,
    input logic x3_val,

    output  logic [data_width:0] result,
    output logic result_val,
    input logic new_row

);

localparam extended_one = {{(data_width-1){1'b0}}, 1'b1};
localparam extended_two = {{(data_width-2){1'b0}}, 2'b10};

// x kernel:
// | -3  0  3 |
// | -10 0 10 |
// | -3  0  3 |

// flip it:
// | 3  0  -3 |
// | 10 0 -10 |
// | 3  0  -3 |

// x 3
logic [data_width+2:0] x_out_1_1, y_out_1_1;
systolic_array_PE#(data_width+3, 1) pe_1_1 (
    .clk(clk),
    .reset(reset),

    .x_in({3'b0,x1}),
    .y_in({(data_width+3){1'b0}}),

    .x_out(x_out_1_1),
    .y_out(y_out_1_1),

    .shamt1(1'b1),
    .shamt2(1'b0)
);


// x 0
logic [data_width+2:0] x_out_1_2, y_out_1_2;
systolic_array_ZeroPE#(data_width+3) pe_1_2 (
    .clk(clk),
    .reset(reset),

    .x_in(x_out_1_1),
    .y_in(y_out_1_1),

    .x_out(x_out_1_2),
    .y_out(y_out_1_2)
);

// x -3
logic [data_width+2:0] x_out_1_3, y_out_1_3;
systolic_array_NegPE#(data_width+3, 1) pe_1_3 (
    .clk(clk),
    .reset(reset),

    .x_in(x_out_1_2),
    .y_in(y_out_1_2),

    .x_out(x_out_1_3),
    .y_out(y_out_1_3),

    .shamt1(1'b1),
    .shamt2(1'b0)
);

// x 10
logic [data_width+4:0] x_out_2_1, y_out_2_1;
systolic_array_PE#(data_width+5, 3) pe_2_1 (
    .clk(clk),
    .reset(reset),

    .x_in({5'b0, x2}),
    .y_in({(data_width+5){1'b0}}),

    .x_out(x_out_2_1),
    .y_out(y_out_2_1),

    .shamt1(3'd3),
    .shamt2(3'd1)
);

// x 0
logic [data_width+4:0] x_out_2_2, y_out_2_2;
systolic_array_ZeroPE#(data_width+5) pe_2_2 (
    .clk(clk),
    .reset(reset),

    .x_in(x_out_2_1),
    .y_in(y_out_2_1),

    .x_out(x_out_2_2),
    .y_out(y_out_2_2)
);

// x -10
logic [data_width+4:0] x_out_2_3, y_out_2_3;
systolic_array_NegPE#(data_width+5, 3) pe_2_3 (
    .clk(clk),
    .reset(reset),

    .x_in(x_out_2_2),
    .y_in(y_out_2_2),

    .x_out(x_out_2_3),
    .y_out(y_out_2_3),

    .shamt1(3'd3),
    .shamt2(3'd1)
);

logic [data_width+2:0] x_out_3_1, y_out_3_1;
systolic_array_PE#(data_width+3, 1) pe_3_1 (
    .clk(clk),
    .reset(reset),

    .x_in({3'b0,x3}),
    .y_in({(data_width + 3){1'b0}}),

    .x_out(x_out_3_1),
    .y_out(y_out_3_1),

    .shamt1(1'b1),
    .shamt2(1'b0)
);

logic [data_width+2:0] x_out_3_2, y_out_3_2;
systolic_array_ZeroPE#(data_width+3) pe_3_2 (
    .clk(clk),
    .reset(reset),

    .x_in(x_out_3_1),
    .y_in(y_out_3_1),

    .x_out(x_out_3_2),
    .y_out(y_out_3_2)
);


logic [data_width+2:0] x_out_3_3, y_out_3_3;
systolic_array_NegPE#(data_width+3, 1) pe_3_3 (
    .clk(clk),
    .reset(reset),

    .x_in(x_out_3_2),
    .y_in(y_out_3_2),

    .x_out(x_out_3_3),
    .y_out(y_out_3_3),

    .shamt1(1'b1),
    .shamt2(1'b0)
);

logic [data_width+5:0] add_result_temp;
logic [data_width+5:0] add_result;
logic [data_width+5:0] shift_result;
logic [data_width+5:0] y_1_3_sext, y_2_3_sext, y_3_3_sext;

vc_SignExtender#(data_width+3, data_width+6) y_1_3_extender (
    .in(y_out_1_3),
    .out(y_1_3_sext)
);

// assign y_2_3_sext = y_out_2_3;

vc_SignExtender#(data_width+5, data_width+6) y_2_3_extender (
    .in(y_out_2_3),
    .out(y_2_3_sext)
);


vc_SignExtender#(data_width+3, data_width+6) y_3_3_extender (
    .in(y_out_3_3),
    .out(y_3_3_sext)
);


vc_SimpleAdder#(data_width+6) result_adder_temp(
    .in0(y_1_3_sext),
    .in1(y_2_3_sext),
    .out(add_result_temp)
);

vc_SimpleAdder#(data_width+6) result_adder(
    .in0(add_result_temp),
    .in1(y_3_3_sext),
    .out(add_result)
);

vc_RightLogicalShifter#(data_width+6, 3) result_shifter(
    .in(add_result),
    .shamt(3'd5),
    .out(shift_result)
);

logic [data_width+5:0] round_shift_result;

logic round_positive;
logic round_negative;
assign round_positive = add_result[4] && !add_result[data_width + 5];
assign round_negative = add_result[4:0] > 5'b10000 && add_result[data_width + 5];
assign round_shift_result = (round_positive || round_negative) ? shift_result + 1'b1 : shift_result;


assign result = round_shift_result[data_width:0];

systolic_array_KernelCellCtrl kernel_cell_x_ctrl (
    .*
);

//----------------------------------------------------------------------
// Input Registers (sequential logic)
//----------------------------------------------------------------------


`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
`VC_TRACE_BEGIN
begin

    $sformat( str, "%x", x1);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "[]" );

    $sformat( str, "%x", x_out_1_1);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "| |" );

    $sformat( str, "%x", x_out_1_1);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "[]" );

    $sformat( str, "%x", x_out_1_2);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "| |" );

    $sformat( str, "%x", x_out_1_2);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "[]" );

    $sformat( str, "%x", x_out_1_3);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "| |\n     " );

    $sformat( str, "%x", 0);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "[]" );

    $sformat( str, "%x", y_out_1_1);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "| |" );

    $sformat( str, "%x", y_out_1_1);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "[]" );

    $sformat( str, "%x", y_out_1_2);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "| |" );

    $sformat( str, "%x", y_out_1_2);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "[]" );

    $sformat( str, "%x", (y_1_3_sext));
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "| |" );

    $sformat( str, "%x", (y_2_3_sext));
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "| |" );

    $sformat( str, "%x", (y_3_3_sext));
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "| |" );

    // $sformat( str, "%x", x2);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", x3);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "||" );

    // $sformat( str, "%x", y_out_1_3);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", y_out_2_3);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", y_out_3_3);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    $sformat( str, "%d", $signed(result));
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "|" );
    $sformat( str, "%x", result_val);
    vc_trace.append_str( trace_str, str );

    $sformat( str, "%x", round_shift_result);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "|" );
    $sformat( str, "%x", result_val);
    vc_trace.append_str( trace_str, str );

    $sformat( str, "%x", shift_result);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "|" );
    $sformat( str, "%x", result_val);
    vc_trace.append_str( trace_str, str );

    $sformat( str, "%x", add_result);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "|" );
    $sformat( str, "%x", result_val);
    vc_trace.append_str( trace_str, str );

    vc_trace.append_str( trace_str, "|\n" );
end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule

`endif /* REG_ARRAY_V */
