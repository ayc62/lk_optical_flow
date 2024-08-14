//========================================================================
// Register Array Implementation
//========================================================================

`ifndef INTERPOLATION_UNIT_V
`define INTERPOLATION_UNIT_V

`include "vc/trace.v"
`include "vc/regs.v"
`include "vc/arithmetic.v"
`include "vc/queues.v"
`include "interpolation_unit/InterpolationUnitCtrl.v"
`include "interpolation_unit/InterpolationUnitDatapath.v"

module interpolation_unit_InterpolationUnit
#(
    parameter pix_width = 9,
    parameter dec_width = 15,
    parameter pix_interp_width = pix_width+dec_width+2
)
(
input  logic        clk,
input  logic        reset,
input logic [4:0] win_dim,

input  logic [pix_width-1:0] pix,
input logic pix_val,
output logic [pix_interp_width-1:0] pix_interp,
output logic pix_interp_val
);

logic [4:0] row_counter;
logic [4:0] col_counter;

logic row_counter_en;
logic deq_rdy;
logic enq_val;

interpolation_unit_InterpolationUnitCtrl #(pix_width, dec_width ) Ctrl (
    .*
);

interpolation_unit_InterpolationUnitDatapath #(pix_width, dec_width ) Datapath (
    .*
);

`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
`VC_TRACE_BEGIN
begin
    // $sformat( str, "%d", state_reg);
    // vc_trace.append_str( trace_str, str );
    // vc_trace.append_str( trace_str, "|" );

end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule

`endif /* pe */