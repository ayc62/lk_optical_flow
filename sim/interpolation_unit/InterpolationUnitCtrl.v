//========================================================================
// Register Array Implementation
//========================================================================

`ifndef INTERPOLATION_UNIT_CTRL_V
`define INTERPOLATION_UNIT_CTRL_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/arithmetic.v"
`include "vc/queues.v"


module interpolation_unit_InterpolationUnitCtrl
#(
    parameter pix_width = 9,
    parameter dec_width = 15,
    parameter pix_interp_width = 32
)
(
input  logic        clk,
input  logic        reset,
input logic [4:0] win_dim,

// datapath <-> ctrl
input logic pix_val,

input  logic[4:0] col_counter,
input  logic[4:0] row_counter,
// input  logic feature_val,

// output logic a_reg_en,
// output logic b_reg_en,
// output logic one_minus_a_reg_en,
// output logic one_minus_b_reg_en,

// output logic mul00_mux_sel,
// output logic mul01_mux_sel,
// output logic mul10_mux_sel,
// output logic mul11_mux_sel,

// output logic iw00_reg_en,
// output logic iw01_reg_en,
// output logic iw10_reg_en,
// output logic iw11_reg_en,

output logic row_counter_en,
output logic deq_rdy,
output logic enq_val,
output logic pix_interp_val
);

logic pix_interp_val_reg_in_1;
logic pix_interp_val_reg_in_2;

vc_ResetReg#(1) pix_interp_val_reg_1 (
    .clk(clk),
    .reset(reset),
    .d(pix_interp_val_reg_in_1),
    .q(pix_interp_val_reg_in_2)
);

vc_ResetReg#(1) pix_interp_val_reg_2 (
    .clk(clk),
    .reset(reset),
    .d(pix_interp_val_reg_in_2),
    .q(pix_interp_val)
);

//----------------------------------------------------------------------
// State Definitions
//----------------------------------------------------------------------

localparam IDLE = 3'd0;
localparam FILL = 3'd1;
localparam L_FILL = 3'd2;
localparam S_FILL_CALC = 3'd3;
localparam FILL_CALC = 3'd4;
localparam L_FILL_CALC = 3'd5;
localparam S_CALC = 3'd6;
localparam CALC = 3'd7;

//----------------------------------------------------------------------
// State
//----------------------------------------------------------------------

logic [2:0] state_reg;
logic [2:0] state_next;
logic [6:0] counter;    // Counter


always_ff @( posedge clk ) begin
    if ( reset ) begin
        state_reg <= IDLE;
    end
    else begin
        state_reg <= state_next;
    end
end

//----------------------------------------------------------------------
// State Transitions
//----------------------------------------------------------------------
logic new_row;
logic new_win;
logic last_row;
// assign new_row = (col_counter == 5'd15) && pix_val;
// assign new_win = (row_counter == 5'd15) && (col_counter == 5'd15) && pix_val;
// assign last_row = (row_counter == 5'd14) && (col_counter == 5'd15) && pix_val;

assign new_row = (col_counter == win_dim) && pix_val;
assign new_win = (row_counter == 5'd0) && (col_counter == 5'd0);
assign last_row = (row_counter == win_dim) && (col_counter == 5'd0) && pix_val;

always_comb begin
    state_next = state_reg;
    case( state_reg )
        IDLE:      if (pix_val)   state_next = FILL;
        FILL:      if (new_row)   state_next = L_FILL;
        L_FILL:      if (pix_val) state_next = S_FILL_CALC;
        S_FILL_CALC: if (pix_val) state_next = FILL_CALC;
        FILL_CALC:  if (new_row)  state_next = L_FILL_CALC;
        L_FILL_CALC: if (last_row)state_next = S_CALC;
                else if (pix_val) state_next = S_FILL_CALC;
        S_CALC:     if (pix_val)  state_next = CALC;
        CALC:      if (new_win)   state_next = IDLE;
        default: state_next = 'x;
    endcase
end

//----------------------------------------------------------------------
// State Outputs
//----------------------------------------------------------------------

function void cs
(
    input logic cs_row_counter_en,
    input logic cs_deq_rdy,
    input logic cs_enq_val,
    input logic cs_pix_interp_val_reg_in_1
    // input logic cs_a_reg_en,
    // input logic cs_b_reg_en,
    // input logic cs_one_minus_a_reg_en,
    // input logic cs_one_minus_b_reg_en,
    // input logic cs_mul00_mux_sel,
    // input logic cs_mul01_mux_sel,
    // input logic cs_mul10_mux_sel,
    // input logic cs_mul11_mux_sel,
    // input logic cs_iw00_reg_en,
    // input logic cs_iw01_reg_en,
    // input logic cs_iw10_reg_en,
    // input logic cs_iw11_reg_en
);
begin
row_counter_en = cs_row_counter_en;
deq_rdy        = cs_deq_rdy;
enq_val        = cs_enq_val;
pix_interp_val_reg_in_1 = cs_pix_interp_val_reg_in_1;
// a_reg_en           = cs_a_reg_en;
// b_reg_en           = cs_b_reg_en;
// one_minus_a_reg_en = cs_one_minus_a_reg_en;
// one_minus_b_reg_en = cs_one_minus_b_reg_en;
// mul00_mux_sel      = cs_mul00_mux_sel;
// mul01_mux_sel      = cs_mul01_mux_sel;
// mul10_mux_sel      = cs_mul10_mux_sel;
// mul11_mux_sel      = cs_mul11_mux_sel;
// iw00_reg_en        = cs_iw00_reg_en;
// iw01_reg_en        = cs_iw01_reg_en;
// iw10_reg_en        = cs_iw10_reg_en;
// iw11_reg_en        = cs_iw11_reg_en;
end
endfunction

always_comb begin
    cs (1'b0, 1'b0, 1'b0, 1'b0);
    //                         row  |         |        | pix   |
    //                         cntr |  deq    |  enq   |interp |
    //                          en  |  rdy    |  val   | val   |
    case (state_reg)
        IDLE: if (pix_val) cs(new_row,    1'b0, pix_val, 1'b0 );
                else       cs(   1'b0,    1'b0,    1'b0, 1'b0 );
        FILL:              cs(new_row,    1'b0, pix_val, 1'b0 );
        L_FILL:            cs(new_row,    1'b0, pix_val, 1'b0 );
        L_FILL_CALC:       cs(new_row, pix_val, pix_val, 1'b1 );
        S_FILL_CALC:       cs(new_row, pix_val, pix_val, 1'b0 );
        FILL_CALC:         cs(new_row, pix_val, pix_val, 1'b1 );
        S_CALC:            cs(new_row, pix_val, pix_val, 1'b0 );
        CALC:              cs(new_row, pix_val, pix_val, 1'b1 );
        default: cs (1'b0, 1'b0, 1'b0, 1'b0);
    endcase
end

`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
`VC_TRACE_BEGIN
begin
    $sformat( str, "%d", state_reg);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "|" );

end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule

`endif /* pe */