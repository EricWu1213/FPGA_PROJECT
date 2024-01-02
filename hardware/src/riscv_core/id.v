module id (
    input        clk,
    input        rst,
    input [31:0] pc,
    input [31:0] inst,
    input        hold_flag,
    input        jump_flag,

    output reg [ 4:0] ra1,
    output reg [ 4:0] ra2,
    input      [31:0] rd1,
    input      [31:0] rd2,

    output reg        csr_we_ex,
    output reg [31:0] csr_wd_ex,
    output reg        we_ex,
    output reg [ 4:0] wa_ex,
    output reg [31:0] op1_ex,
    output reg [31:0] op2_ex,
    output reg [31:0] rd1_ex,
    output reg [31:0] rd2_ex,
    output reg [31:0] op1_jump_ex,
    output reg [31:0] op2_jump_ex,
    output reg [31:0] inst_ex,
    output reg [31:0] pc_ex,

    output        mem0_en,
    output [11:0] mem0_raddr,
    output        mem1_en,
    output [13:0] mem1_raddr,
    output        mem2_en,
    output [9:0] mem2_raddr
);

    wire [ 6:0] opcode;
    wire [ 2:0] funct3;
    wire [ 2:0] funct7;
    wire [ 4:0] rd;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    reg         csr_we;
    reg  [31:0] csr_wd;
    reg         we;
    reg  [ 4:0] wa;
    reg  [31:0] op1;
    reg  [31:0] op2;
    wire [31:0] op1_add_op2;
    reg         mem_en_id;
    reg  [31:0] mem_raddr_id;
    reg  [31:0] op1_jump;
    reg  [31:0] op2_jump;

    assign opcode      = inst[6:0];
    assign funct3      = inst[14:12];
    assign funct7      = inst[31:25];
    assign rd          = inst[11:7];
    assign rs1         = inst[19:15];
    assign rs2         = inst[24:20];
    assign op1_add_op2 = op1 + op2;

    assign mem0_en     = mem_en_id & (mem_raddr_id[31:28] == 4'b0100);
    assign mem1_en     = mem_en_id & (mem_raddr_id[31:30] == 2'b00) & mem_raddr_id[28];
    assign mem2_en     = mem_en_id & (mem_raddr_id[31:28] == 4'b1000);
    assign mem0_raddr  = mem_raddr_id[13:2];
    assign mem1_raddr  = mem_raddr_id[15:2];
    assign mem2_raddr  = mem_raddr_id[11:2];

    always @(*) begin
        we = 0;
        wa = 0;
        ra1 = 0;
        ra2 = 0;
        op1 = 0;
        op2 = 0;
        mem_en_id = 0;
        mem_raddr_id = 0;
        csr_we = 0;
        csr_wd = 0;
        op1_jump = 0;
        op2_jump = 0;
        case (opcode)
            `OPC_ARI_ITYPE: begin
                case (funct3)
                    `FNC_ADD_SUB, `FNC_SLL, `FNC_SLT, `FNC_SLTU, `FNC_XOR, `FNC_OR, `FNC_AND, `FNC_SRL_SRA: begin
                        we  = 1'b1;
                        wa  = rd;
                        ra1 = rs1;
                        ra2 = 0;
                        op1 = rd1;
                        op2 = {{20{inst[31]}}, inst[31:20]};
                    end
                    default: begin
                    end
                endcase
            end
            `OPC_ARI_RTYPE: begin
                if ((funct7 == `FNC7_0) | (funct7 == `FNC7_1)) begin
                    case (funct3)
                        `FNC_ADD_SUB, `FNC_SLL, `FNC_SLT, `FNC_SLTU, `FNC_XOR, `FNC_OR, `FNC_AND, `FNC_SRL_SRA: begin
                            we  = 1'b1;
                            wa  = rd;
                            ra1 = rs1;
                            ra2 = rs2;
                            op1 = rd1;
                            op2 = rd2;
                        end
                        default: begin
                        end
                    endcase
                end
            end
            `OPC_LOAD: begin
                case (funct3)
                    `FNC_LB, `FNC_LH, `FNC_LW, `FNC_LBU, `FNC_LHU: begin
                        we = 1'b1;
                        wa = rd;
                        ra1 = rs1;
                        ra2 = 0;
                        op1 = rd1;
                        op2 = {{20{inst[31]}}, inst[31:20]};
                        mem_en_id = 1'b1;
                        mem_raddr_id = op1_add_op2;
                    end
                    default: begin
                    end
                endcase
            end
            `OPC_STORE: begin
                case (funct3)
                    `FNC_SB, `FNC_SH, `FNC_SW: begin
                        ra1 = rs1;
                        ra2 = rs2;
                        op1 = rd1;
                        op2 = {{20{inst[31]}}, inst[31:25], inst[11:7]};
                    end
                    default: begin
                    end
                endcase
            end
            `OPC_BRANCH: begin
                case (funct3)
                    `FNC_BEQ, `FNC_BNE, `FNC_BLT, `FNC_BGE, `FNC_BLTU, `FNC_BGEU: begin
                        ra1 = rs1;
                        ra2 = rs2;
                        op1 = rd1;
                        op2 = rd2;
                        op1_jump = pc;
                        op2_jump = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
                    end
                    default: begin
                    end
                endcase
            end
            `OPC_JAL: begin
                we = 1'b1;
                wa = rd;
                op1 = pc;
                op2 = 32'h4;
                op1_jump = pc;
                op2_jump = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end
            `OPC_JALR: begin
                we = 1'b1;
                wa = rd;
                ra1 = rs1;
                op1 = pc;
                op2 = 32'h4;
                op1_jump = rd1;
                op2_jump = {{20{inst[31]}}, inst[31:20]};
            end
            `OPC_LUI: begin
                we  = 1'b1;
                wa  = rd;
                op1 = {inst[31:12], 12'h0};
                op2 = 0;
            end
            `OPC_AUIPC: begin
                we  = 1'b1;
                wa  = rd;
                op1 = pc;
                op2 = {inst[31:12], 12'h0};
            end
            `OPC_CSR: begin
                csr_we = (inst[31:20] == 12'h51e);
                ra1 = rs1;
                csr_wd = (funct3 == 3'b001) ? rd1 : {27'h0, inst[19:15]};
            end
            default: begin
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst | jump_flag | hold_flag) begin
            csr_we_ex <= 0;
            csr_wd_ex <= 0;
            we_ex <= 0;
            wa_ex <= 0;
            op1_ex <= 0;
            op2_ex <= 0;
            rd1_ex <= 0;
            rd2_ex <= 0;
            op1_jump_ex <= 0;
            op2_jump_ex <= 0;
            inst_ex <= 0;
            pc_ex <= 0;
        end else begin
            csr_we_ex <= csr_we;
            csr_wd_ex <= csr_wd;
            we_ex <= we;
            wa_ex <= wa;
            op1_ex <= op1;
            op2_ex <= op2;
            rd1_ex <= rd1;
            rd2_ex <= rd2;
            op1_jump_ex <= op1_jump;
            op2_jump_ex <= op2_jump;
            inst_ex <= inst;
            pc_ex <= pc;
        end
    end

endmodule
