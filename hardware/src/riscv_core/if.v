module if_top (
    input        clk,
    input        rst,
    input [31:0] rst_pc,
    input        hold_flag,
    input        jump_flag,
    input [31:0] jump_addr,

    output        mem0_en,
    output [11:0] mem0_addr,
    input  [31:0] mem0_data,

    output wire        mem1_en,
    output      [13:0] mem1_addr,
    input       [31:0] mem1_data,

    output [31:0] inst,
    output [31:0] pc_inst
);

    reg [31:0] pc;
    reg [31:0] pc_r;
    reg mem0_data_vld;
    reg mem1_data_vld;

    always @(posedge clk) begin
        if (rst) pc_r <= rst_pc;
        else pc_r <= pc;
    end
    // wire asser_veri = (rst==1 &&pc==rst_pc)|| rst==0;
    assert_iverilog  assert_iverilog_pc (clk, ( rst==1 &&pc==rst_pc) || rst==0);
    
    always @(*) begin
        if (rst) pc = rst_pc;
        else if (hold_flag) pc = pc_r;
        else if (jump_flag) pc = jump_addr;
        else pc = pc_r + 32'h4;
    end

    assign mem0_en   = (pc[31:28] == 4'b0100);
    assign mem0_addr = pc[13:2];
    wire en_ref;
    assign en_ref = (pc[28] == 1'b1) && (pc[31:29] == 3'b0);
    assign mem1_en = 1'b1;
    assign mem1_addr = pc[15:2];

    always @(posedge clk) begin
        //if(rst) begin
        //    mem0_data_vld <= 0;
        //    mem1_data_vld <= 0;
        //end else begin
        mem0_data_vld <= mem0_en;
        mem1_data_vld <= en_ref;
        //end
    end

    assign inst = jump_flag ? 0 : mem0_data_vld ? mem0_data : mem1_data_vld ? mem1_data : 0;
    assign pc_inst = jump_flag ? 0 : pc_r;

endmodule
