//========================================================================
// Register Array Implementation
//========================================================================

`ifndef CONV_FEEDER_V
`define CONV_FEEDER_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/arithmetic.v"
`include "vc/queues.v"


module conv_feeder_ConvFeeder #(
    parameter data_width = 32
)
(
    input  logic        clk,
    input  logic        reset,

    input logic [3:0] win_dim,

    input logic enq_val,
    output logic enq_rdy [2:0],
    input logic [data_width-1:0] enq_msg,

    output logic deq_val [2:0],
    output logic deq_rdy [2:0],
    output logic [data_width-1:0] deq_msg [2:0],
    output logic new_row

);

localparam QUEUE_SIZE = 6'd32;
//----------------------------------------
// Data Path
//----------------------------------------
logic enq_val_mux_out_1;
logic enq_val_mux_out_2;
logic enq_val_mux_out_3;
logic [data_width-1:0] enq_msg_mux_out_1;
logic [data_width-1:0] enq_msg_mux_out_2;
logic reset_queues;
logic [4:0] num_free_entries_1, num_free_entries_2, num_free_entries_3;

vc_Queue #(.p_type(`VC_QUEUE_PIPE),
            .p_msg_nbits(data_width), 
            .p_num_msgs(QUEUE_SIZE)
) queue_1 (
    .clk(clk),
    .reset(reset || reset_queues),
    .enq_val(enq_val_mux_out_1),
    .enq_rdy(enq_rdy[0]),
    .enq_msg(enq_msg_mux_out_1),
    .deq_val(deq_val[0]),
    .deq_rdy(deq_rdy[0]),
    .deq_msg(deq_msg[0]),
    .num_free_entries(num_free_entries_1)
);

vc_Queue #(.p_type(`VC_QUEUE_PIPE),
            .p_msg_nbits(data_width), 
            .p_num_msgs(QUEUE_SIZE)
) queue_2 (
    .clk(clk),
    .reset(reset || reset_queues),
    .enq_val(enq_val_mux_out_2),
    .enq_rdy(enq_rdy[1]),
    .enq_msg(enq_msg_mux_out_2),
    .deq_val(deq_val[1]),
    .deq_rdy(deq_rdy[1]),
    .deq_msg(deq_msg[1]),
    .num_free_entries(num_free_entries_2)
);

vc_Queue #(.p_type(`VC_QUEUE_PIPE),
            .p_msg_nbits(data_width), 
            .p_num_msgs(QUEUE_SIZE)
) queue_3 (
    .clk(clk),
    .reset(reset || reset_queues),
    .enq_val(enq_val_mux_out_3),
    .enq_rdy(enq_rdy[2]),
    .enq_msg(enq_msg),
    .deq_val(deq_val[2]),
    .deq_rdy(deq_rdy[2]),
    .deq_msg(deq_msg[2]),
    .num_free_entries(num_free_entries_3)
);

logic [1:0] enq_val_mux_sel_1;
logic [1:0] enq_val_mux_sel_2;
logic enq_val_mux_sel_3;

vc_Mux3 #(1) enq_val_mux_1(
    .in0(enq_val),
    .in1(!last_row),
    .in2(1'b0),
    .out(enq_val_mux_out_1),
    .sel(enq_val_mux_sel_1)
);

vc_Mux3 #(1) enq_val_mux_2(
    .in0(enq_val),
    .in1(!last_row),
    .in2(1'b0),
    .out(enq_val_mux_out_2),
    .sel(enq_val_mux_sel_2)
);

vc_Mux2 #(1) enq_val_mux_3(
    .in0(enq_val),
    .in1(1'b0),
    .out(enq_val_mux_out_3),
    .sel(enq_val_mux_sel_3)
);

logic enq_msg_mux_sel_1;
logic enq_msg_mux_sel_2;
logic [data_width-1:0] queue_2_deq_msg;
logic [data_width-1:0] queue_3_deq_msg;

assign queue_2_deq_msg = deq_msg[1];
assign queue_3_deq_msg = deq_msg[2];

vc_Mux2 #(data_width) enq_msg_mux_1(
    .in0(enq_msg),
    .in1(queue_2_deq_msg),
    .out(enq_msg_mux_out_1),
    .sel(enq_msg_mux_sel_1)
);

vc_Mux2 #(data_width) enq_msg_mux_2(
    .in0(enq_msg),
    .in1(queue_3_deq_msg),
    .out(enq_msg_mux_out_2),
    .sel(enq_msg_mux_sel_2)
);

logic [4:0] col_counter, row_counter, deq_col_counter, deq_row_counter;
logic [4:0] next_col_counter, next_row_counter, next_deq_col_counter, next_deq_row_counter;
logic col_counter_sel, row_counter_sel, deq_col_counter_sel, deq_row_counter_sel;
logic col_counter_en, row_counter_en, deq_col_counter_en, deq_row_counter_en;

logic [4:0] col_counter_plus, row_counter_plus, deq_col_counter_plus, deq_row_counter_plus;
logic [4:0] win_dim_plus;
logic [4:0] win_dim_plus_one;

always_comb begin
    col_counter_plus = col_counter + 1;
    row_counter_plus = row_counter + 1;
    deq_col_counter_plus = deq_col_counter + 1;
    deq_row_counter_plus = deq_row_counter + 1;
    win_dim_plus = win_dim + 5'd2;
    win_dim_plus_one = win_dim + 5'd1;

    next_col_counter = (col_counter_sel) ?
                        ((col_counter_plus == win_dim_plus) ? 5'b0 : col_counter_plus)
                        : 5'b0;
    next_row_counter = (row_counter_sel) ?
                        row_counter_plus
                        : 5'b0;
    next_deq_col_counter = (deq_col_counter_sel) ?
                        ((deq_col_counter_plus == win_dim_plus) ? 5'b0 : deq_col_counter_plus)
                        : 5'b0;
    next_deq_row_counter = (deq_row_counter_sel) ?
                        deq_row_counter_plus
                        : 5'b0;
end

always @(posedge clk ) begin
    if (enq_val || col_counter_en) col_counter <= next_col_counter;
    if ((enq_val && next_col_counter == 5'b0) || row_counter_en) row_counter <= next_row_counter;
    if (deq_col_counter_en) deq_col_counter <= next_deq_col_counter;
    if ((deq_col_counter_en && (next_deq_col_counter == 5'b0)) || deq_row_counter_en) deq_row_counter <= next_deq_row_counter;
end

//----------------------------------------
// Control Unit
//----------------------------------------

//----------------------------------------
// State transitions
//----------------------------------------
localparam IDLE = 3'd0;
localparam FILL_1 = 3'd1;
localparam FILL_2 = 3'd2;
localparam FILL_3 = 3'd3;
localparam CALC = 3'd4;
localparam WAIT = 3'd5;

logic [2:0] state_reg;
logic [2:0] next_state_reg;

always_ff @(posedge clk) begin
    if (reset) state_reg <= IDLE;
    else state_reg <= next_state_reg;
end
logic [4:0] num_entries_1, num_entries_2, num_entries_3;
logic window_done, row_done, do_wait, last_row;
assign window_done = row_counter == win_dim_plus;
assign row_done = enq_val && (col_counter == win_dim_plus_one);
assign last_row = deq_row_counter == win_dim_plus_one;
assign do_wait = !(enq_val && num_entries_3 == win_dim_plus_one) && !(num_entries_3 == win_dim_plus);

always_comb begin
    num_entries_1 = QUEUE_SIZE - num_free_entries_1;
    num_entries_2 = QUEUE_SIZE - num_free_entries_2;
    num_entries_3 = QUEUE_SIZE - num_free_entries_3;

    next_state_reg = state_reg;

    case(state_reg)
        IDLE: if (enq_val) next_state_reg = FILL_1;
        FILL_1: if (row_done) next_state_reg = FILL_2;
        FILL_2: if (row_done) next_state_reg = FILL_3;
        FILL_3: if (row_done) next_state_reg = CALC;
        CALC: begin
            if (next_deq_col_counter == 0 && window_done) next_state_reg = IDLE;
            else if (next_deq_col_counter == 0 && do_wait) next_state_reg = WAIT;
        end
        WAIT: if (row_done) next_state_reg = CALC;
        default: next_state_reg = 'x;
    endcase

end
//----------------------------------------
// State Outputs
//----------------------------------------
localparam val = 2'b0;
localparam one = 2'd1;
localparam zero = 2'd2;

localparam val_3 = 1'b0;
localparam zero_3 = 1'b1;

localparam enq_m = 1'b0;
localparam deq_m = 1'b1;

localparam next_c = 1'b1;
localparam zero_c = 1'b0;

logic calc_row_done;
assign calc_row_done = deq_col_counter == 5'b0;

function void cs
(
    input logic [2:0] cs_enq_val_mux_sel_1,
    input logic [2:0] cs_enq_val_mux_sel_2,
    input logic cs_enq_val_mux_sel_3,

    input logic cs_enq_msg_mux_sel_1,
    input logic cs_enq_msg_mux_sel_2,

    input logic cs_deq_rdy_1,
    input logic cs_deq_rdy_2,
    input logic cs_deq_rdy_3,
    
    input logic cs_col_counter_sel,
    input logic cs_row_counter_sel,
    input logic cs_deq_col_counter_sel,
    input logic cs_deq_row_counter_sel,

    input logic cs_col_counter_en,
    input logic cs_row_counter_en,
    input logic cs_deq_col_counter_en,
    input logic cs_deq_row_counter_en,

    input logic cs_reset_queues,
    input logic cs_new_row
);
begin
enq_val_mux_sel_1 = cs_enq_val_mux_sel_1;
enq_val_mux_sel_2 = cs_enq_val_mux_sel_2;
enq_val_mux_sel_3 = cs_enq_val_mux_sel_3;

enq_msg_mux_sel_1 = cs_enq_msg_mux_sel_1;
enq_msg_mux_sel_2 = cs_enq_msg_mux_sel_2;

deq_rdy[0] = cs_deq_rdy_1;
deq_rdy[1] = cs_deq_rdy_2;
deq_rdy[2] = cs_deq_rdy_3;

col_counter_sel = cs_col_counter_sel;
row_counter_sel = cs_row_counter_sel;
deq_col_counter_sel = cs_deq_col_counter_sel;
deq_row_counter_sel = cs_deq_row_counter_sel;

col_counter_en = cs_col_counter_en;
row_counter_en = cs_row_counter_en;
deq_col_counter_en = cs_deq_col_counter_en;
deq_row_counter_en = cs_deq_row_counter_en;

reset_queues = cs_reset_queues;

new_row = cs_new_row;
end
endfunction

always_comb begin
    cs( zero, zero, zero_3, enq_m, enq_m, 1'b0, 1'b0, 1'b0, zero_c, zero_c, zero_c, zero_c, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
    //                           enq val | enq val | enq val | enq msg | enq msg | deq | deq | deq |  col  |  row  | deqc  | deqr  | col  | row  | deqc | deqr |     |
    //                            mux 1  |  mux 2  |  mux 3  |  mux 1  |  mux 2  | rdy | rdy | rdy |  cntr |  cntr |  cntr |  cntr | cntr | cntr | cntr | cntr | rst |  new
    //                            sel    |  sel    |  sel    |   sel   |   sel   |  1  |  2  |  3  |  sel  |  sel  |  sel  |  sel  |  en  |  en  |  en  |  en  |  q  |  row
    case (state_reg)
        IDLE: if (enq_val)    cs(  val,    zero,     zero_3,    enq_m,    enq_m,    0,    0,    0,  next_c,  next_c, zero_c, zero_c, 1'b0,  1'b0,  1'b0,  1'b0,  1'b0, 1'b0);
              else            cs( zero,    zero,     zero_3,    enq_m,    enq_m,    0,    0,    0,  zero_c,  zero_c, zero_c, zero_c, 1'b1,  1'b1,  1'b1,  1'b1,  1'b0, 1'b0);
        FILL_1:               cs(  val,    zero,     zero_3,    enq_m,    enq_m,    0,    0,    0,  next_c,  next_c, zero_c, zero_c, 1'b0,  1'b0,  1'b0,  1'b0,  1'b0, 1'b0);
        FILL_2:               cs( zero,     val,     zero_3,    enq_m,    enq_m,    0,    0,    0,  next_c,  next_c, zero_c, zero_c, 1'b0,  1'b0,  1'b0,  1'b0,  1'b0, 1'b0);
        FILL_3: if (row_done) cs(  one,     one,        val,    deq_m,    deq_m,    1,    1,    1,  next_c,  next_c, next_c, next_c, 1'b0,  1'b0,  1'b1,  1'b1,  1'b0, 1'b0);
                else          cs( zero,    zero,        val,    enq_m,    enq_m,    0,    0,    0,  next_c,  next_c, zero_c, zero_c, 1'b0,  1'b0,  1'b0,  1'b0,  1'b0, 1'b0);
        CALC:                 cs(  one,     one,        val,    deq_m,    deq_m,    1,    1,    1,  next_c,  next_c, next_c, next_c, 1'b0,  1'b0,  1'b1,  1'b0,  1'b0, calc_row_done);
        WAIT:   if (row_done) cs(  one,     one,        val,    deq_m,    deq_m,    1,    1,    1,  next_c,  next_c, next_c, next_c, 1'b0,  1'b0,  1'b1,  1'b0,  1'b0, 1'b0);
                else          cs( zero,    zero,        val,    enq_m,    enq_m,    0,    0,    0,  next_c,  next_c, next_c, next_c, 1'b0,  1'b0,  1'b0,  1'b0,  1'b0, 1'b0);
        default:              cs( zero,    zero,     zero_3,    enq_m,    enq_m,    0,    0,    0,  next_c,  next_c, next_c, next_c, 1'b0,  1'b0,  1'b0,  1'b0,  1'b0, 1'b0);
    endcase
end

`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
logic [`VC_TRACE_NBITS-1:0] state_str;
always_comb begin
    case (state_reg)
        IDLE: state_str = "IDLE";
        FILL_1: state_str = "FILL_1";
        FILL_2: state_str = "FILL_2";
        FILL_3: state_str = "FILL_3";
        CALC: state_str = "CALC";
        WAIT: state_str = "WAIT";
        default: state_str = "default";
    endcase
end
`VC_TRACE_BEGIN
begin

    // $sformat( str, "%0d", enq_msg);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );
    // $sformat( str, "%0d", enq_val);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_1.genblk2.dpath.qstore.rfile[3]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_1.genblk2.dpath.qstore.rfile[2]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_1.genblk2.dpath.qstore.rfile[1]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_1.genblk2.dpath.qstore.rfile[0]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "||" );

    // $sformat( str, "%x", deq_msg[0]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", deq_rdy[0]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // vc_trace.append_str( trace_str, "\n" );
    // vc_trace.append_str( trace_str, "         " );

    // $sformat( str, "%x", queue_2.genblk2.dpath.qstore.rfile[3]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_2.genblk2.dpath.qstore.rfile[2]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_2.genblk2.dpath.qstore.rfile[1]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_2.genblk2.dpath.qstore.rfile[0]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "||" );

    // $sformat( str, "%x", deq_msg[1]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", deq_rdy[1]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // vc_trace.append_str( trace_str, "\n" );
    // vc_trace.append_str( trace_str, "         " );


    // $sformat( str, "%x", queue_3.genblk2.dpath.qstore.rfile[3]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_3.genblk2.dpath.qstore.rfile[2]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_3.genblk2.dpath.qstore.rfile[1]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", queue_3.genblk2.dpath.qstore.rfile[0]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "||" );

    // $sformat( str, "%x", deq_msg[2]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", deq_rdy[2]);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );


    // vc_trace.append_str( trace_str, "  " );
    // // vc_trace.append_str( trace_str, "\n" );
    // // vc_trace.append_str( trace_str, "         " );

    // $sformat( str, "%x", col_counter);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", row_counter);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", deq_col_counter);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // $sformat( str, "%x", deq_row_counter);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );


    // vc_trace.append_str( trace_str, state_str );

    // $sformat( str, "|%x", new_row);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

    // vc_trace.append_str( trace_str, "\n" );

end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule

`endif /* REG_ARRAY_V */
