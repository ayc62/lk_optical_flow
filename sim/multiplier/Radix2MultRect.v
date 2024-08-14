`ifndef RADIX_2_ARRAY_MULT_V
`define RADIX_2_ARRAY_MULT_V

`include "vc/arithmetic.v"
`include "vc/regs.v"
`include "vc/trace.v"
`include "multiplier/FinalRowCell.v"
`include "multiplier/ArrayCell.v"
`include "multiplier/ArrayCellComplement.v"

module multiplier_Radix2MultRect
#(
    parameter x_width = 4,
    parameter y_width = 6,
    // assume y_width > x_width

    parameter p_width = x_width + y_width,
    parameter num_rows = x_width + 1,
    parameter num_cols = y_width
)(
input  logic        clk,
input  logic        reset,

input  logic        istream_val,
output logic        istream_rdy,
input  logic [x_width+y_width-1:0] istream_msg,

output logic        ostream_val,
input  logic        ostream_rdy,
output logic [p_width-1:0] ostream_msg


);
logic [y_width-1:0] y;
logic [x_width-1:0] x;
logic [p_width-1:0] p;
assign istream_rdy = ostream_rdy;
assign ostream_val = istream_val;
assign y = istream_msg[y_width-1:0];
assign x = istream_msg[y_width+x_width-1:y_width];
assign ostream_msg = p;

// input logic s_in,
// input logic a,
// input logic c_in,
// input logic b,
// output logic c_out,
// output logic s_out

// logic [x_width-1:0] x_reg_out;
// vc_ResetReg
// #(
//   x_width
// )x_reg(
//   .q(x_reg_out),     // Data output
//   .d(x),     // Data input
//   .*
// );

// logic [y_width-1:0] y_reg_out;
// vc_ResetReg
// #(
//   y_width
// )y_reg(
//   .q(y_reg_out),     // Data output
//   .d(y),     // Data input
//   .*
// );

// logic [p_width-1:0] p_reg_in;
// vc_ResetReg
// #(
//   p_width
// )p_reg(
//   .q(p),     // Data output
//   .d(p_reg_in),     // Data input
//   .*
// );

logic [num_cols-1:0] s_out [num_rows];
logic [num_cols-1:0] c_out [num_rows];
logic [num_cols-1:0] s_in [num_rows-1];
logic [num_cols-1:0] c_in [num_rows];
logic [num_cols-1:0] a [num_rows];
logic [num_cols-1:0] b [num_rows];

genvar row;
genvar col;
generate
for (row = 0; row < num_rows - 2 ; row = row + 1) begin
    for (col = 0; col < num_cols - 1 ; col = col + 1) begin
        multiplier_ArrayCell square (
            .clk  (clk),
            .reset(reset),
            .s_in ( s_in[row][col]),
            .a    (    a[row][col]),
            .c_in ( c_in[row][col]),
            .b    (    b[row][col]),
            .c_out(c_out[row][col]),
            .s_out(s_out[row][col])
        );
    end
    multiplier_ArrayCellComplement col_comp(
        .clk  (clk),
        .reset(reset),
        .s_in ( s_in[row][num_cols-1]),
        .a    (    a[row][num_cols-1]),
        .c_in ( c_in[row][num_cols-1]),
        .b    (    b[row][num_cols-1]),
        .c_out(c_out[row][num_cols-1]),
        .s_out(s_out[row][num_cols-1])
    );
end

for (col = 0; col < num_cols-1; col = col + 1) begin
    multiplier_ArrayCellComplement row_comp(
        .clk  (clk),
        .reset(reset),
        .s_in ( s_in[num_rows-2][col]),
        .a    (    a[num_rows-2][col]),
        .c_in ( c_in[num_rows-2][col]),
        .b    (    b[num_rows-2][col]),
        .c_out(c_out[num_rows-2][col]),
        .s_out(s_out[num_rows-2][col])
    );
end

multiplier_ArrayCell corner_cell (
    .clk  (clk),
    .reset(reset),
    .s_in ( s_in[num_rows - 2][num_cols - 1]),
    .a    (    a[num_rows - 2][num_cols - 1]),
    .c_in ( c_in[num_rows - 2][num_cols - 1]),
    .b    (    b[num_rows - 2][num_cols - 1]),
    .c_out(c_out[num_rows - 2][num_cols - 1]),
    .s_out(s_out[num_rows - 2][num_cols - 1])
);

for (col = 0; col < num_cols; col = col + 1) begin
    multiplier_FinalRowCell final_row (
        .clk  (clk),
        .reset(reset),
        .a    (    a[num_rows-1][col]),
        .c_in ( c_in[num_rows-1][col]),
        .b    (    b[num_rows-1][col]),
        .c_out(c_out[num_rows-1][col]),
        .s_out(s_out[num_rows-1][col])
    );
end

// first row inputs
for (col = 0; col < num_cols; col = col + 1) begin
    always_comb begin
        c_in[0][col] = 1'b0;
        s_in[0][col] = (col == x_width - 1) || (col == y_width - 1);
    end
    for (row = 0; row < num_rows - 1; row = row+1) begin
        always_comb begin
            a[row][col] = y[col];
            b[row][col] = x[row];
        end
    end
end

// sout -> sin connections
for (row = 1; row < num_rows-1 ; row = row + 1) begin
    for (col = 0; col < num_cols -1 ; col = col + 1) begin
        always_comb begin
            s_in[row][col] = s_out[row - 1][col+1];
        end
    end
end

// cout -> cin connections
for (row = 1; row < num_rows - 1 ; row = row + 1) begin
    for (col = 0; col < num_cols ; col = col + 1) begin
        always_comb begin
            c_in[row][col] = c_out[row - 1][col];
        end
    end
end

for (row = 1; row < num_rows - 1; row = row + 1) begin
    assign s_in[row][num_cols - 1] = 1'b0;
end

for (row = 0; row < num_rows - 1; row = row + 1 ) begin
    assign p[row] = s_out[row][0];
end

// last row b
for (col = 0; col < num_cols; col = col + 1) begin
    assign b[num_rows-1][col] = c_out[num_rows-2][col];
end

// last row a
for (col = 0; col < num_cols - 1; col = col + 1) begin
    assign a[num_rows-1][col] = s_out[num_rows-2][col+1];
end

// last row cout -> cin
for (col = 1; col < num_cols; col = col + 1) begin
    assign c_in[num_rows-1][col] = c_out[num_rows-1][col - 1];
end

// last row p
for (col = 0; col < num_cols; col = col + 1) begin
    assign p[col + x_width] = s_out[num_rows-1][col];
end

endgenerate

assign a[num_rows-1][num_cols-1] = 1'b1;
assign c_in[num_rows-1][0] = 1'b0;

`ifndef SYNTHESIS
logic [`VC_TRACE_NBITS-1:0] str;
parameter print_row = 6;
`VC_TRACE_BEGIN
begin
    $sformat( str, "cin|a|b||cout|sout\n     ");
    vc_trace.append_str( trace_str, str );
    for (int print_col = num_cols - 1; print_col >= 0; print_col = print_col - 1) begin
        
        $sformat( str, "%x", c_in[print_row][print_col]);
        vc_trace.append_str( trace_str, str );
        vc_trace.append_str( trace_str, "|" );
        // $sformat( str, "%x", s_in[print_row][print_col]);
        // vc_trace.append_str( trace_str, str );
        // vc_trace.append_str( trace_str, "|" );
        $sformat( str, "%x", a[print_row][print_col]);
        vc_trace.append_str( trace_str, str );
        vc_trace.append_str( trace_str, "|" );
        $sformat( str, "%x", b[print_row][print_col]);
        vc_trace.append_str( trace_str, str );
        vc_trace.append_str( trace_str, " || " );


        $sformat( str, "%x", c_out[print_row][print_col]);
        vc_trace.append_str( trace_str, str );
        vc_trace.append_str( trace_str, "||" );
        $sformat( str, "%x", s_out[print_row][print_col]);
        vc_trace.append_str( trace_str, str );
        vc_trace.append_str( trace_str, "\n     " );
    end
    $sformat( str, "%x", p);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "\n" );
     $sformat( str, "%x", x);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "\n" );
    $sformat( str, "%x", y);
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, "\n" );
end
`VC_TRACE_END

`endif /* SYNTHESIS */

endmodule

`endif
