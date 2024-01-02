`include "opcode.vh"
module ex (
    input        clk,
    input        rst,
    input        csr_we,
    input [31:0] pc,
    input [31:0] inst,
    input [31:0] rd1,
    input [31:0] rd2,
    input [31:0] op1,
    input [31:0] op2,
    input [31:0] op1_jump,
    input [31:0] op2_jump,
    input [31:0] mem_rdata,

    output reg [31:0] wd,
    output reg        jump_flag,
    output reg [31:0] jump_addr,

    output            mem0_en,
    output            mem1_en,
    output            mem2_en,
    output reg [ 3:0] mem_we,
    output reg [31:0] mem_wd,
    output     [13:0] mem_wa,

    output reg ex_done
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [2:0] funct7;

    wire signed_ge = ($signed(op1) >= $signed(op2));
    wire unsigned_ge = ((op1) >= (op2));
    wire [31:0] sri_shift_msk = 32'hffffffff >> inst[24:20];
    wire [31:0] sri_shift = rd1 >> inst[24:20];
    wire [31:0] sr_shift_msk = 32'hffffffff >> rd2[4:0];
    wire [31:0] sr_shift = rd1 >> rd2[4:0];
    wire [31:0] op1_add_op2 = op1 + op2;
    wire [31:0] mem_addr = op1_add_op2;
    wire [31:0] op1_add_op2_jump = op1_jump + op2_jump;

    assign opcode  = inst[6:0];
    assign funct3  = inst[14:12];
    assign funct7  = inst[31:25];

    assign mem0_en = (mem_addr[31:30] == 2'h0) & mem_addr[28];
    assign mem1_en = (mem_addr[31:29] == 3'b001);
    assign mem2_en = (mem_addr[31:28] == 4'b1000);
    assign mem_wa  = mem_addr[15:2];

    // wire io_fcw_en = (mem_addr[31:8]==24'h800002);
    reg assert_store;
    // assert_iverilog assert_st (
    //     clk,
    //     rst || (opcode == `OPC_STORE && assert_store == 1 ) || opcode != `OPC_STORE
    // );
    reg assert_load;
    // assert_iverilog assert_ld (
    //     clk,
    //     rst || (opcode == `OPC_LOAD && assert_load == 1 ) || opcode != `OPC_LOAD
    // );

    always @(*) begin
        jump_flag = 1'b0;
        jump_addr = 0;
        mem_wd = 32'h0;
        mem_we = 4'b0000;
        wd = 32'h0;
        ex_done = 1'b0;

        case (opcode)
            `OPC_ARI_ITYPE: begin
                case (funct3)
                    `FNC_ADD_SUB: begin
                        wd = op1_add_op2;
                        ex_done = 1'b1;
                    end
                    `FNC_SLL: begin
                        wd = rd1 << inst[24:20];
                        ex_done = 1'b1;
                    end
                    `FNC_SLT: begin
                        wd = {31'h0, (~signed_ge)};
                        ex_done = 1'b1;
                    end
                    `FNC_SLTU: begin
                        wd = {31'h0, (~unsigned_ge)};
                        ex_done = 1'b1;
                    end
                    `FNC_XOR: begin
                        wd = op1 ^ op2;
                        ex_done = 1'b1;
                    end
                    `FNC_OR: begin
                        wd = op1 | op2;
                        ex_done = 1'b1;
                    end
                    `FNC_AND: begin
                        wd = op1 & op2;
                        ex_done = 1'b1;
                    end
                    `FNC_SRL_SRA: begin
                        if (inst[30] == `FNC2_SRA) begin
                            wd = (sri_shift & sri_shift_msk) | ({32{rd1[31]}} & (~sri_shift_msk));
                        end else begin
                            wd = rd1 >> inst[24:20];
                        end
                        ex_done = 1'b1;
                    end
                    default: begin
                    end
                endcase
            end
            `OPC_ARI_RTYPE: begin
                if ((funct7 == `FNC7_0) | (funct7 == `FNC7_1)) begin
                    case (funct3)
                        `FNC_ADD_SUB: begin
                            if (inst[30] == `FNC2_ADD) begin
                                wd = op1_add_op2;
                            end else begin
                                wd = op1 - op2;
                            end
                            ex_done = 1'b1;
                        end
                        `FNC_SLL: begin
                            wd = op1 << op2[4:0];
                            ex_done = 1'b1;
                        end
                        `FNC_SLT: begin
                            wd = {31'h0, (~signed_ge)};
                            ex_done = 1'b1;
                        end
                        `FNC_SLTU: begin
                            wd = {31'h0, (~unsigned_ge)};
                            ex_done = 1'b1;
                        end
                        `FNC_XOR: begin
                            wd = op1 ^ op2;
                            ex_done = 1'b1;
                        end
                        `FNC_OR: begin
                            wd = op1 | op2;
                            ex_done = 1'b1;
                        end
                        `FNC_AND: begin
                            wd = op1 & op2;
                            ex_done = 1'b1;
                        end
                        `FNC_SRL_SRA: begin
                            if (inst[30] == `FNC2_SRA) begin
                                wd = (sr_shift & sr_shift_msk) | ({32{rd1[31]}} & (~sr_shift_msk));
                            end else begin
                                wd = rd1 >> rd2[4:0];
                            end
                            ex_done = 1'b1;
                        end
                        default: begin
                        end
                    endcase
                end
            end
            `OPC_LOAD: begin
                case (funct3)
                    `FNC_LB: begin
                        case (mem_addr[1:0])
                            2'd0: wd = {{24{mem_rdata[7]}}, mem_rdata[7:0]};
                            2'd1: wd = {{24{mem_rdata[15]}}, mem_rdata[15:8]};
                            2'd2: wd = {{24{mem_rdata[23]}}, mem_rdata[23:16]};
                            default: wd = {{24{mem_rdata[31]}}, mem_rdata[31:24]};
                        endcase
                        ex_done = 1'b1;
                        assert_load = 1;
                    end
                    `FNC_LH: begin
                        wd = (mem_addr[1:0] == 2'h0) ? {{16{mem_rdata[15]}}, mem_rdata[15:0]} : 
                                                   {{16{mem_rdata[31]}}, mem_rdata[31:16]} ;
                        ex_done = 1'b1;
                        assert_load = 1;
                    end
                    `FNC_LW: begin
                        wd = mem_rdata;
                        ex_done = 1'b1;
                        assert_load = 1;
                    end
                    `FNC_LBU: begin
                        case (mem_addr[1:0])
                            2'd0: wd = {24'h0, mem_rdata[7:0]};
                            2'd1: wd = {24'h0, mem_rdata[15:8]};
                            2'd2: wd = {24'h0, mem_rdata[23:16]};
                            default: wd = {24'h0, mem_rdata[31:24]};
                        endcase
                        ex_done = 1'b1;
                        assert_load = 1;
                    end
                    `FNC_LHU: begin
                        wd = (mem_addr[1:0] == 2'h0) ? {16'h0, mem_rdata[15:0]} : 
                                                   {16'h0, mem_rdata[31:16]} ;
                        ex_done = 1'b1;
                        assert_load = 1;
                    end
                    default: begin
                        assert_load = 0;
                    end
                endcase
            end
            `OPC_STORE: begin
                case (funct3)
                    `FNC_SB: begin
                        case (mem_addr[1:0])
                            2'd0: begin
                                mem_wd = rd2;
                                mem_we = 4'b0001;
                                assert_store = 1'b1;
                            end
                            2'd1: begin
                                mem_wd = {16'h0, rd2[7:0], 8'h0};
                                mem_we = 4'b0010;
                                assert_store = 1'b1;
                            end
                            2'd2: begin
                                mem_wd = {8'h0, rd2[7:0], 16'h0};
                                mem_we = 4'b0100;
                                assert_store = 1'b1;
                            end
                            default: begin
                                mem_wd = {rd2[7:0], 24'h0};
                                mem_we = 4'b1000;
                                assert_store = 1'b1;
                            end
                        endcase
                        ex_done = 1'b1;
                    end
                    `FNC_SH: begin
                        mem_wd  = (mem_addr[1:0] == 0) ? rd2 : {rd2[15:0], 16'h0};
                        mem_we  = (mem_addr[1:0] == 0) ? 4'b0011 : 4'b1100;
                        ex_done = 1'b1;
                        assert_store = 1'b1;
                    end
                    `FNC_SW: begin
                        mem_wd  = rd2;
                        mem_we  = 4'b1111;
                        ex_done = 1'b1;
                        assert_store = 1'b1;
                    end
                    default: begin
                        assert_store = 1'b0;
                    end
                endcase
            end
            `OPC_BRANCH: begin
                case (funct3)
                    `FNC_BEQ: begin
                        jump_flag = (op1 == op2);
                        jump_addr = op1_add_op2_jump;
                        ex_done   = 1'b1;
                    end
                    `FNC_BNE: begin
                        jump_flag = ~(op1 == op2);
                        jump_addr = op1_add_op2_jump;
                        ex_done   = 1'b1;
                    end
                    `FNC_BLT: begin
                        jump_flag = ~signed_ge;
                        jump_addr = op1_add_op2_jump;
                        ex_done   = 1'b1;
                    end
                    `FNC_BGE: begin
                        jump_flag = signed_ge;
                        jump_addr = op1_add_op2_jump;
                        ex_done   = 1'b1;
                    end
                    `FNC_BLTU: begin
                        jump_flag = ~unsigned_ge;
                        jump_addr = op1_add_op2_jump;
                        ex_done   = 1'b1;
                    end
                    `FNC_BGEU: begin
                        jump_flag = unsigned_ge;
                        jump_addr = op1_add_op2_jump;
                        ex_done   = 1'b1;
                    end
                    default: begin
                    end
                endcase
            end
            `OPC_JAL, `OPC_JALR: begin
                jump_flag = 1'b1;
                jump_addr = op1_add_op2_jump;
                wd = op1_add_op2;
                ex_done = 1'b1;
            end
            `OPC_LUI, `OPC_AUIPC: begin
                wd = op1_add_op2;
                ex_done = 1'b1;
            end
            `OPC_CSR: begin
                ex_done = 1'b1;
            end
            default: begin
                ex_done = 1'b0;
            end
        endcase
    end

endmodule
