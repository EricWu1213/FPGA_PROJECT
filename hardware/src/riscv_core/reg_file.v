module reg_file (
    input clk,
    input rst,
    input we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output reg [31:0] rd1, rd2
);
    parameter DEPTH = 32;
    reg [31:0] mem [0:31];
//    assign rd1 = 32'd0;
//    assign rd2 = 32'd0;

    // wire asser_veri = (ra1==5'b0 && rd1==32'b0) ||ra1!=5'b0 ;
    assert_iverilog assert_reg1(clk,rst ||(ra1==5'b0 && rd1==32'b0) ||ra1!=5'b0);
    assert_iverilog assert_reg2(clk,rst ||(ra2==5'b0 && rd2==32'b0) ||ra2!=5'b0);
    always@(posedge clk) begin
        if(we & (wa != 5'h0)) begin
            mem[wa] <= wd;
        end
    end

    always@(*) begin
        if(ra1 == 5'h0) begin
            rd1 = 32'h0;
        end else if(we & (ra1 == wa)) begin
            rd1 = wd;
        end else begin
            rd1 = mem[ra1];
        end
    end

    always@(*) begin
        if(ra2 == 5'h0) begin
            rd2 = 32'h0;
        end else if(we & (ra2 == wa)) begin
            rd2 = wd;
        end else begin
            rd2 = mem[ra2];
        end
    end

endmodule
