//========================================================================
// Register Array Implementation
//========================================================================

`ifndef CONV_UNIT_V
`define CONV_UNIT_V

`include "vc/trace.v"
`include "vc/regs.v"

`include "conv_feeder/ConvFeeder.v"
`include "systolic_array/KernelCellX.v"
`include "systolic_array/KernelCellY.v"


module conv_unit_ConvUnit
#(
    parameter data_width = 8
)(
input  logic        clk,
input  logic        reset,

input logic [3:0] win_dim,

input  logic [data_width-1:0] pix,
input logic pix_val,
output logic [data_width:0] Ix,
output logic Ix_val,
output logic [data_width:0] Iy,
output logic Iy_val
);


logic enq_rdy [2:0];
logic deq_val [2:0];
logic deq_rdy [2:0];

logic [data_width-1:0] deq_msg [2:0];

logic [data_width:0] Ix_reg_in;
logic Ix_val_reg_in;
logic [data_width:0] Iy_reg_in;
logic Iy_val_reg_in;

vc_ResetReg#(data_width+1) Ix_reg
(
    .clk(clk),
    .reset(reset),
    .d(Ix_reg_in),
    .q(Ix)
);

vc_ResetReg#(1) Ix_val_reg
(
    .clk(clk),
    .reset(reset),
    .d(Ix_val_reg_in),
    .q(Ix_val)
);

vc_ResetReg#(data_width+1) Iy_reg
(
    .clk(clk),
    .reset(reset),
    .d(Iy_reg_in),
    .q(Iy)
);

vc_ResetReg#(1) Iy_val_reg
(
    .clk(clk),
    .reset(reset),
    .d(Iy_val_reg_in),
    .q(Iy_val)
);

logic new_row;

conv_feeder_ConvFeeder #(
    data_width
) conv_feeder
(
    .clk(clk),
    .reset(reset),

    .win_dim(win_dim),

    .enq_val(pix_val),
    .enq_rdy(enq_rdy),
    .enq_msg(pix),

    .deq_val(deq_val),
    .deq_rdy(deq_rdy),
    .deq_msg(deq_msg),
    .new_row(new_row)

);

systolic_array_KernelCellX #(
    data_width
) kernel_cell_x
(
    .clk(clk),
    .reset(reset),

    .x1    (deq_msg[0]),
    .x1_val(deq_rdy[0]),
    .x2    (deq_msg[1]),
    .x2_val(deq_rdy[1]),
    .x3    (deq_msg[2]),
    .x3_val(deq_rdy[2]),

    .result(Ix_reg_in),
    .result_val(Ix_val_reg_in),

    .new_row(new_row)

);

systolic_array_KernelCellY #(
    data_width
) kernel_cell_y
(
    .clk(clk),
    .reset(reset),

    .x1    (deq_msg[0]),
    .x1_val(deq_rdy[0]),
    .x2    (deq_msg[1]),
    .x2_val(deq_rdy[1]),
    .x3    (deq_msg[2]),
    .x3_val(deq_rdy[2]),

    .result(Iy_reg_in),
    .result_val(Iy_val_reg_in),

    .new_row(new_row)

);

`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
`VC_TRACE_BEGIN
begin
    // $sformat( str, "%d", pix);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%x", pix_val);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|\n" );

    // $sformat( str, "%d", deq_msg[0]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%x", deq_rdy[0]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%d", deq_msg[1]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%x", deq_rdy[1]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%d", deq_msg[2]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%x", deq_rdy[2]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%x", new_row);
    // vc_trace.append_str( trace_str, str );


    // vc_trace.append_str( trace_str, "|\n" );

    // $sformat( str, "%d", $signed(Ix));
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%x", Ix_val);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|\n" );
    // $sformat( str, "%d", $signed(Iy));
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%x", Iy_val);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|\n" );

end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule

`endif /* pe */