module cpu #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 115200,
    parameter N_VOICES = 4
) (
    input  clk,
    input  rst,
    input  serial_in,
    output serial_out,

    input cpu_ack,
    output reg cpu_req,
    output reg [24*N_VOICES-1:0] synth_carrier_fcws,
    output reg [23:0] synth_mod_fcw,
    output reg [4:0] synth_mod_shift,
    output reg [N_VOICES-1:0] synth_note_en,
    output reg [4:0] synth_shift,
    input button_empty,
    input [3:0] button_data,
    input [1:0] switches,
    output button_rd_en,
    output reg [5:0] leds
);


    // BIOS Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    wire [11:0] bios_addra, bios_addrb;
    wire [31:0] bios_douta, bios_doutb;
    wire bios_ena, bios_enb;
    bios_mem bios_mem (
        .clk  (clk),
        .ena  (bios_ena),
        .addra(bios_addra),
        .douta(bios_douta),
        .enb  (bios_enb),
        .addrb(bios_addrb),
        .doutb(bios_doutb)
    );

     wire io_ren;
    wire [9:0] io_raddr;
    reg [31:0] io_data;
    reg [31:0] uart_txdata;
    reg [31:0] ccnt;
    reg [31:0] icnt;
    reg [31:0] tohost_csr = 0;
    wire ex_done;
    wire [31:0] inst;
    wire [31:0] pc;
    wire jump_flag;
    wire [31:0] jump_addr;
    wire csr_we;
    wire [31:0] csr_wd;
    wire dmem_ren;
    wire [13:0] dmem_raddr;
    wire [31:0] op1_ex;
    wire [31:0] op2_ex;
    wire [31:0] rd1_ex;
    wire [31:0] rd2_ex;
    wire [31:0] op1_jump_ex;
    wire [31:0] op2_jump_ex;
    wire [31:0] inst_ex;
    wire [31:0] pc_ex;
    reg rd_sel_bios;
    reg rd_sel_dmem;
    reg rd_sel_io;
    wire [31:0] mem_rdata;
    wire dmem_wen;
    wire [3:0] mem_we;
    wire [13:0] mem_wa;
    wire [31:0] mem_wd;
    // Data Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    wire [13:0] dmem_addr;
    wire [31:0] dmem_din, dmem_dout;
    reg [31:0] dmem_din_dly;
    wire [3:0] dmem_we;
    wire dmem_en;
    reg [3:0] dmem_haz;
    wire hold_id;
    dmem dmem (
        .clk (clk),
        .en  (dmem_en),
        .we  (dmem_we),
        .addr(dmem_addr),
        .din (dmem_din),
        .dout(dmem_dout)
    );

    always @(posedge clk) begin
        if (rst) dmem_din_dly <= 0;
        else dmem_din_dly <= dmem_din;
    end

    always @(posedge clk) begin
        if (rst) dmem_haz <= 0;
        else begin
            dmem_haz[3] <= (dmem_ren & dmem_wen & (mem_we[3]) & (dmem_raddr == mem_wa));
            dmem_haz[2] <= (dmem_ren & dmem_wen & (mem_we[2]) & (dmem_raddr == mem_wa));
            dmem_haz[1] <= (dmem_ren & dmem_wen & (mem_we[1]) & (dmem_raddr == mem_wa));
            dmem_haz[0] <= (dmem_ren & dmem_wen & (mem_we[0]) & (dmem_raddr == mem_wa));
        end
    end

    assign hold_id = (dmem_ren & dmem_wen & (|mem_we) & (dmem_raddr != mem_wa));
    // Instruction Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    wire [31:0] imem_dina, imem_doutb;
    wire [13:0] imem_addra, imem_addrb;
    wire [3:0] imem_wea;
    wire imem_wen;
    wire io_wen;
    wire imem_ena;
    imem imem (
        .clk  (clk),
        .ena  (imem_ena|imem_wen),
        .wea  (imem_wea&{4{!io_wen}}),
        .addra(imem_addra),
        .dina (imem_dina),
        .addrb(imem_addrb),
        .doutb(imem_doutb)
    );

    // Register file
    // Asynchronous read: read data is available in the same cycle
    // Synchronous write: write takes one cycle
    wire we;
    wire [4:0] ra1, ra2, wa;
    wire [31:0] rd1, rd2, wd;
    reg_file rf (
        .clk(clk),
        .rst(rst),
        .we (we),
        .ra1(ra1),
        .ra2(ra2),
        .wa (wa),
        .wd (wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // On-chip UART
    //// UART Receiver
    wire [7:0] uart_rx_data_out;
    wire uart_rx_data_out_valid;
    wire uart_rx_data_out_ready;
    //// UART Transmitter
    wire [7:0] uart_tx_data_in;
    wire uart_tx_data_in_valid;
    wire uart_tx_data_in_ready;
   

    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) on_chip_uart (
        .clk  (clk),
        .reset(rst),

        .serial_in(serial_in),
        .data_out(uart_rx_data_out),
        .data_out_valid(uart_rx_data_out_valid),
        .data_out_ready(uart_rx_data_out_ready),

        .serial_out(serial_out),
        .data_in(uart_tx_data_in),
        .data_in_valid(uart_tx_data_in_valid),
        .data_in_ready(uart_tx_data_in_ready)
    );

    assign uart_rx_data_out_ready = io_ren & (io_raddr == 10'b001);
    assign uart_tx_data_in_valid = io_wen & (|mem_we) & (mem_wa[2:0] == 3'b010);
    assign uart_tx_data_in = {24'h0, mem_wd[7:0]};

    assign button_rd_en = io_ren && ( io_raddr== 12'h24>>2 )  ;

    always @(posedge clk) begin
        if (io_ren) begin
            case (io_raddr)
                10'b000: io_data <= {30'h0, uart_rx_data_out_valid, uart_tx_data_in_ready};
                10'b001: io_data <= {24'h0, uart_rx_data_out};
                10'b100: io_data <= ccnt;
                10'b101: io_data <= icnt;
                12'h20>>2: io_data <= {31'b0, button_empty};
                12'h24>>2: io_data <= {29'd0, button_data[3:1]};
                12'h28>>2: io_data <= {30'b0, switches};
                12'h214>>2: io_data <= {31'b0, cpu_ack};
                default: io_data <= 32'h0;
            endcase
        end
    end
    always @(posedge clk) begin
        if (rst) begin
            synth_carrier_fcws <= 0;
            synth_mod_fcw <= 0;
            synth_mod_shift <= 0;
            synth_note_en <= 0;
            cpu_req <= 0;
            leds <= 0;
        end else if (io_wen)
            case (mem_wa)
                16'h30 >> 2: leds <= mem_wd[5:0];
                16'h100 >> 2: synth_carrier_fcws[1*24-1:0] <= mem_wd[23:0];
                16'h104 >> 2: synth_carrier_fcws[2*24-1:1*24] <= mem_wd[23:0];
                16'h108 >> 2: synth_carrier_fcws[3*24-1:2*24] <= mem_wd[23:0];
                16'h10C >> 2: synth_carrier_fcws[4*24-1:3*24] <= mem_wd[23:0];
                16'h200 >> 2: synth_mod_fcw <= mem_wd[23:0];
                16'h204 >> 2: synth_mod_shift <= mem_wd[4:0];
                16'h208 >> 2: synth_note_en <= mem_wd[N_VOICES-1:0];
                16'h20C >> 2: synth_shift <= mem_wd[4:0];
                16'h210 >> 2: cpu_req <= mem_wd[0];
                default: ;
            endcase
    end

    always @(posedge clk) begin
        if (rst) ccnt <= 0;
        else if (io_wen & (mem_wa[2:0] == 3'b110)) ccnt <= 0;
        else ccnt <= ccnt + 32'd1;
    end

    always @(posedge clk) begin
        if (rst) icnt <= 0;
        else if (io_wen & (mem_wa[2:0] == 3'b110)) icnt <= 0;
        else if (ex_done) icnt <= icnt + 32'd1;
    end
    // TODO: Your code to implement a fully functioning RISC-V core
    // Add as many modules as you want
    // Feel free to move the memory modules around
    /*******************************************/
    //if
    /*******************************************/
    if_top u_if (
        .clk(clk),
        .rst(rst),
        .rst_pc(RESET_PC),
        .hold_flag(hold_id),
        .jump_flag(jump_flag),
        .jump_addr(jump_addr),
        .mem0_en(bios_ena),
        .mem0_addr(bios_addra),
        .mem0_data(bios_douta),
        .mem1_en(imem_ena),
        .mem1_addr(imem_addrb),
        .mem1_data(imem_doutb),
        .inst(inst),
        .pc_inst(pc)
    );

    /*******************************************/
    //id
    /*******************************************/
    id u_id (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .inst(inst),
        .hold_flag(hold_id),
        .jump_flag(jump_flag),
        .ra1(ra1),
        .ra2(ra2),
        .rd1(rd1),
        .rd2(rd2),

        .csr_we_ex(csr_we),
        .csr_wd_ex(csr_wd),
        .we_ex(we),
        .wa_ex(wa),
        .op1_ex(op1_ex),
        .op2_ex(op2_ex),
        .rd1_ex(rd1_ex),
        .rd2_ex(rd2_ex),
        .op1_jump_ex(op1_jump_ex),
        .op2_jump_ex(op2_jump_ex),
        .inst_ex(inst_ex),
        .pc_ex(pc_ex),

        .mem0_en(bios_enb),
        .mem0_raddr(bios_addrb),
        .mem1_en(dmem_ren),
        .mem1_raddr(dmem_raddr),
        .mem2_en(io_ren),
        .mem2_raddr(io_raddr)
    );

    always @(posedge clk) begin
        if (csr_we) begin
            tohost_csr <= csr_wd;
        end
    end

    /*******************************************/
    //ex
    /*******************************************/

    wire [31:0] dmem_dout_cmb;
    assign dmem_dout_cmb[31:24] = ({8{dmem_haz[3]}} & dmem_din_dly[31:24]) | ({8{~dmem_haz[3]}} & dmem_dout[31:24]);
    assign dmem_dout_cmb[23:16] = ({8{dmem_haz[2]}} & dmem_din_dly[23:16]) | ({8{~dmem_haz[2]}} & dmem_dout[23:16]);
    assign dmem_dout_cmb[15:8]  = ({8{dmem_haz[1]}} & dmem_din_dly[15:8] ) | ({8{~dmem_haz[1]}} & dmem_dout[15:8] );
    assign dmem_dout_cmb[7:0]   = ({8{dmem_haz[0]}} & dmem_din_dly[7:0]  ) | ({8{~dmem_haz[0]}} & dmem_dout[7:0]  );


    assign mem_rdata = rd_sel_bios ? bios_doutb : rd_sel_dmem ? dmem_dout_cmb : rd_sel_io ? io_data : 0;
    always @(posedge clk) begin
        if (rst) begin
            rd_sel_bios <= 0;
            rd_sel_dmem <= 0;
            rd_sel_io   <= 0;
        end else begin
            rd_sel_bios <= bios_enb;
            rd_sel_dmem <= dmem_ren;
            rd_sel_io   <= io_ren;
        end
    end

    ex u_ex (
        .clk(clk),
        .rst(rst),
        .csr_we(csr_we),
        .pc(pc_ex),
        .inst(inst_ex),
        .op1(op1_ex),
        .op2(op2_ex),
        .rd1(rd1_ex),
        .rd2(rd2_ex),
        .op1_jump(op1_jump_ex),
        .op2_jump(op2_jump_ex),
        .mem_rdata(mem_rdata),

        .wd(wd),
        .jump_flag(jump_flag),
        .jump_addr(jump_addr),

        .mem0_en(dmem_wen),
        .mem1_en(imem_wen),
        .mem2_en(io_wen),
        .mem_we (mem_we),
        .mem_wd (mem_wd),
        .mem_wa (mem_wa),
        .ex_done(ex_done)
    );

    assign dmem_en = dmem_ren | dmem_wen;
    assign dmem_we = mem_we & {4{dmem_wen}};
    assign dmem_addr = hold_id ? mem_wa : dmem_ren ? dmem_raddr[13:0] : dmem_wen ? mem_wa : 0;
    assign dmem_din = mem_wd;

    // assign imem_ena = imem_wen;
    assign imem_wea = mem_we;
    assign imem_addra = mem_wa;
    assign imem_dina = mem_wd;

    // 
    // edge_detector #(
    //     .WIDTH(WIDTH)
    // ) edge_detector_inst (
    //     .clk(clk),
    //     .signal_in(signal_in),
    //     .edge_detect_pulse(edge_detect_pulse)
    // );



endmodule
