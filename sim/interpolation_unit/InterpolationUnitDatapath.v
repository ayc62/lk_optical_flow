//========================================================================
// Register Array Implementation
//========================================================================

`ifndef INTERPOLATION_UNIT_DATAPATH_V
`define INTERPOLATION_UNIT_DATAPATH_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/arithmetic.v"
`include "vc/queues.v"
`include "vc/muxes.v"
`include "multiplier/SimpleMultWrapper.v"


module interpolation_unit_InterpolationUnitDatapath
#(
    parameter pix_width = 9,
    parameter dec_width = 15,

    parameter mul_width = pix_width + dec_width,
    parameter pix_interp_width = mul_width + 2
)
(
input  logic        clk,
input  logic        reset,
input logic [4:0] win_dim,

// input logic [dec_width-1:0] feature_x_dec,
// input logic [dec_width-1:0] feature_y_dec,
// input logic feature_val,
input  logic [pix_width-1:0] pix,
input logic pix_val,
output logic [pix_interp_width-1:0] pix_interp,

// datapath <-> ctrl

// input logic a_reg_en,
// input logic b_reg_en,
// input logic one_minus_a_reg_en,
// input logic one_minus_b_reg_en,

// input logic mul00_mux_sel,
// input logic mul01_mux_sel,
// input logic mul10_mux_sel,
// input logic mul11_mux_sel,

// input logic iw00_reg_en,
// input logic iw01_reg_en,
// input logic iw10_reg_en,
// input logic iw11_reg_en,

output logic [4:0] row_counter,
output logic [4:0] col_counter,

input logic row_counter_en,
input logic deq_rdy,
input logic enq_val
);

logic [pix_width-1:0] pix_queue_deq_msg;
logic enq_rdy;
logic deq_val;
vc_Queue #(.p_type(`VC_QUEUE_PIPE),
            .p_msg_nbits(pix_width),
            .p_num_msgs(17)
) pix_queue (
    .clk(clk),
    .reset(reset),
    .enq_val(enq_val),
    .enq_rdy(enq_rdy),
    .enq_msg(pix),
    .deq_val(deq_val),
    .deq_rdy(deq_rdy),
    .deq_msg(pix_queue_deq_msg),
    .num_free_entries()
);

logic [pix_width-1:0] w00;
logic [pix_width-1:0] w01;
logic [pix_width-1:0] w10;
logic [pix_width-1:0] w11;


vc_EnResetReg#(pix_width) w00_reg
(
    .clk(clk),
    .reset(reset),
    .en(pix_val),
    .d(pix_queue_deq_msg),
    .q(w00)
);

vc_EnResetReg#(pix_width) w10_reg
(
    .clk(clk),
    .reset(reset),
    .en(pix_val),
    .d(w11),
    .q(w10)
);

vc_EnResetReg#(pix_width) w11_reg
(
    .clk(clk),
    .reset(reset),
    .en(pix_val),
    .d(pix),
    .q(w11)
);


assign w01     = pix_queue_deq_msg;

logic [dec_width-1:0] iw00;
logic [dec_width-1:0] iw01;
logic [dec_width-1:0] iw10;
logic [dec_width-1:0] iw11;

assign iw00 = {{dec_width-1{1'b0}}, 1'b1};
assign iw01 = {{dec_width-1{1'b0}}, 1'b1};
assign iw10 = {{dec_width-1{1'b0}}, 1'b1};
assign iw11 = {{dec_width-1{1'b0}}, 1'b1};

// logic [dec_width-1:0] a;
// logic [dec_width-1:0] b;
// logic [dec_width-1:0] one_minus_a;
// logic [dec_width-1:0] one_minus_b;
// logic a_reg_en, b_reg_en, one_minus_a_reg_en, one_minus_b_reg_en;
// vc_EnResetReg#(dec_width) a_reg
// (
//     .clk(clk),
//     .reset(reset),
//     .en(a_reg_en),
//     .d(feature_x_dec),
//     .q(a)
// );

// vc_EnResetReg#(dec_width) b_reg
// (
//     .clk(clk),
//     .reset(reset),
//     .en(b_reg_en),
//     .d(feature_y_dec),
//     .q(b)
// );

// logic [dec_width:0] one_minus_a_reg_in, one_minus_b_reg_in;
// assign one_minus_a_reg_in = {1'b1, {dec_width-1{1'b0}}} - {1'b0, a};
// assign one_minus_b_reg_in = {1'b1, {dec_width-1{1'b0}}} - {1'b0, b};

// vc_EnResetReg#(dec_width) one_minus_a_reg
// (
//     .clk(clk),
//     .reset(reset),
//     .en(one_minus_a_reg_en),
//     .d(one_minus_a_reg_in[dec_width-1:0]),
//     .q(one_minus_a)
// );

// vc_EnResetReg#(dec_width) one_minus_b_reg
// (
//     .clk(clk),
//     .reset(reset),
//     .en(one_minus_b_reg_en),
//     .d(one_minus_b_reg_in[dec_width-1:0]),
//     .q(one_minus_b)
// );

// logic mul00_mux_sel, mul01_mux_sel, mul10_mux_sel, mul11_mux_sel;
// logic [dec_width-1:0] mul00_x, mul00_y, mul01_x, mul01_y, mul10_x, mul10_y, mul11_x, mul11_y;
// vc_Mux2 #(dec_width) mul00_mux_x
// (
//     .sel(mul00_mux_sel),
//     .in0(one_minus_a),
//     .in1(iw00),
//     .out(mul00_x)
// );

// vc_Mux2 #(dec_width) mul00_mux_y
// (
//     .sel(mul00_mux_sel),
//     .in0(one_minus_b),
//     .in1(w00),
//     .out(mul00_y)
// );

// vc_Mux2 #(dec_width) mul01_mux_x
// (
//     .sel(mul01_mux_sel),
//     .in0(a),
//     .in1(iw01),
//     .out(mul01_x)
// );

// vc_Mux2 #(dec_width) mul01_mux_y
// (
//     .sel(mul01_mux_sel),
//     .in0(one_minus_b),
//     .in1(w01),
//     .out(mul01_y)
// );

// vc_Mux2 #(dec_width) mul10_mux_x
// (
//     .sel(mul10_mux_sel),
//     .in0(one_minus_a),
//     .in1(iw10),
//     .out(mul10_x)
// );

// vc_Mux2 #(dec_width) mul10_mux_y
// (
//     .sel(mul10_mux_sel),
//     .in0(b),
//     .in1(w10),
//     .out(mul10_y)
// );

logic [mul_width-1:0] mul00;
logic [mul_width-1:0] mul01;
logic [mul_width-1:0] mul10;
logic [mul_width-1:0] mul11;
multiplier_SimpleMult#(dec_width, pix_width) multiplier00 (
    .x    (iw00),
    .y    ( w00),
    .p    ( mul00)
);

multiplier_SimpleMult#(dec_width, pix_width) multiplier01 (
    .x    (iw01),
    .y    ( w01),
    .p    ( mul01)
);

multiplier_SimpleMult#(dec_width, pix_width) multiplier10 (
    .x    (iw10),
    .y    ( w10),
    .p    ( mul10)
);

multiplier_SimpleMult#(dec_width, pix_width) multiplier11 (
    .x    (iw11),
    .y     (w11),
    .p     (mul11)
);

// logic iw00_reg_en, iw01_reg_en, iw10_reg_en, iw11_reg_en;

// vc_EnResetReg#(dec_width) iw00_reg
// (
//     .clk(clk),
//     .reset(reset),
//     .en(iw00_reg_en),
//     .d(mul00),
//     .q(iw00)
// );

// vc_EnResetReg#(dec_width) iw01_reg
// (
//     .clk(clk),
//     .reset(reset),
//     .en(iw01_reg_en),
//     .d(mul01),
//     .q(iw01)
// );

// vc_EnResetReg#(dec_width) iw10_reg
// (
//     .clk(clk),
//     .reset(reset),
//     .en(iw10_reg_en),
//     .d(mul10),
//     .q(iw10)
// );

// logic [dec_width:0] iw11_reg_in;
// assign iw11_reg_in = ({1'b1, {dec_width-1{1'b0}}} - {1'b1, iw00}) -
//                      ({1'b0, iw10} + {1'b1, iw11})

// vc_EnResetReg#(dec_width) iw11_reg
// (
//     .clk(clk),
//     .reset(reset),
//     .en(iw11_reg_en),
//     .d(iw11_reg_in[dec_width-1:0]),
//     .q(iw11)
// );

logic [mul_width-1:0] mul00_reg_out;
logic [mul_width-1:0] mul01_reg_out;
logic [mul_width-1:0] mul10_reg_out;
logic [mul_width-1:0] mul11_reg_out;

vc_ResetReg #(mul_width) mul00_reg
(
    .clk(clk),
    .reset(reset),
    .d(mul00),
    .q(mul00_reg_out)
);

vc_ResetReg #(mul_width) mul01_reg
(
    .clk(clk),
    .reset(reset),
    .d(mul01),
    .q(mul01_reg_out)
);

vc_ResetReg #(mul_width) mul10_reg
(
    .clk(clk),
    .reset(reset),
    .d(mul10),
    .q(mul10_reg_out)
);

vc_ResetReg #(mul_width) mul11_reg
(
    .clk(clk),
    .reset(reset),
    .d(mul11),
    .q(mul11_reg_out)
);



logic [mul_width:0] top_row_add;
vc_Adder#(mul_width) top_row_adder (
    .in0(mul00_reg_out),
    .in1(mul01_reg_out),
    .cin(1'b0),
    .out(top_row_add[mul_width-1:0]),
    .cout(top_row_add[mul_width])
);

logic [mul_width:0] bottom_row_add;
vc_Adder#(mul_width) bottonw_row_adder (
    .in0(mul10_reg_out),
    .in1(mul11_reg_out),
    .cin(1'b0),
    .out(bottom_row_add[mul_width-1:0]),
    .cout(bottom_row_add[mul_width])
);

logic [mul_width+1:0] final_add;
vc_Adder#(mul_width+2) final_adder (
    .in0(top_row_add),
    .in1(bottom_row_add),
    .cin(1'b0),
    .out(final_add[mul_width:0]),
    .cout(final_add[mul_width+1])
);

vc_ResetReg#(mul_width+2) interp_result_reg (
    .clk(clk),
    .reset(reset),
    .d(final_add),
    .q(pix_interp)
);

vc_EnResetReg#(5) col_counter_reg (
    .clk(clk),
    .reset(reset),
    .en(pix_val),
    .d((col_counter == win_dim) ? 5'd0 : col_counter + 5'd1),
    .q(col_counter)
);

vc_EnResetReg#(5) row_counter_reg (
    .clk(clk),
    .reset(reset),
    .en(row_counter_en),
    .d((row_counter == win_dim) ? 5'd0 : row_counter + 5'd1),
    .q(row_counter)
);

`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
`VC_TRACE_BEGIN
begin
    for (int ind = 15; ind >= 0; ind = ind - 1) begin
        // $sformat( str, "%x", pix_queue.genblk2.dpath.qstore.rfile[ind]);
        // vc_trace.append_str( trace_str, str );
        vc_trace.append_str( trace_str, "|" );
    end
    vc_trace.append_str( trace_str, "|" );
    $sformat( str, "%x", w00);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "\n" );

    $sformat( str, "%x", pix);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "|" );

    $sformat( str, "%x", w10);
    vc_trace.append_str( trace_str, str );
end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule

`endif /* pe */