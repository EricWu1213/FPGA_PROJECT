module cpu_to_synth_cdc #(
    parameter N_VOICES = 1
) (
    input cpu_clk,
    input [24*N_VOICES-1:0] cpu_carrier_fcws,
    input [23:0] cpu_mod_fcw,
    input [4:0] cpu_mod_shift,
    input [N_VOICES-1:0] cpu_note_en,
    input [4:0] cpu_synth_shift,
    input cpu_req,
    output cpu_ack,

    input synth_clk,
    output reg [24*N_VOICES-1:0] synth_carrier_fcws,
    output reg [23:0] synth_mod_fcw,
    output reg [4:0] synth_mod_shift,
    output reg [N_VOICES-1:0] synth_note_en,
    output reg [4:0] synth_synth_shift
);
    // Remove these lines once you have implemented this module

    wire cpu_req_clk_synth;
    synchronizer #(
        .WIDTH(1)
    ) synchronizer_inst_req (
        .async_signal(cpu_req),
        .clk(synth_clk),
        .sync_signal(cpu_req_clk_synth)
    );

    reg synth_clk_req_reg;
    always @(posedge synth_clk) begin
        synth_clk_req_reg <= cpu_req_clk_synth;
    end

    wire cpu_ack_clk_cpu;
    synchronizer #(
        .WIDTH(1)
    ) synchronizer_inst_ack (
        .async_signal(synth_clk_req_reg),
        .clk(cpu_clk),
        .sync_signal(cpu_ack)
    );

    // genvar i;
    always @(posedge synth_clk) begin
        if (synth_clk_req_reg) begin
            synth_note_en <= cpu_note_en;
            synth_carrier_fcws <= cpu_carrier_fcws;
            // generate
            // for (i = 0; i < N_VOICES; i++) begin
            //     synth_note_en[i] <= cpu_note_en[i];
            //     synth_carrier_fcws[(i+1)*23-1:i*23] <= cpu_carrier_fcws[(i+1)*23-1:i*23];
            // end
            // endgenerate
            synth_mod_fcw <= cpu_mod_fcw;
            synth_mod_shift <= cpu_mod_shift;
            synth_synth_shift <= cpu_synth_shift;
        end

    end
endmodule
