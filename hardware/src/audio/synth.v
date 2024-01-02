module synth #(
    parameter N_VOICES = 4
) (
    input clk,
    input rst,
    input [24*N_VOICES-1:0] carrier_fcws,
    input [23:0] mod_fcw,
    input [4:0] mod_shift,
    input [N_VOICES-1:0] note_en,

    output [13:0] sample,
    output sample_valid,
    input sample_ready
);
    // Remove these lines once you have implemented this module

    localparam STATE_FETCH_MOD = 0;  // fetch modulator samples
    localparam STATE_SET_FCW = 1;  // compute fcw of carrier
    localparam STATE_FETCH_CAR = 2;  // fetch carrier samples
    localparam STATE_SUM = 3;  // sum carrier samples
    localparam STATE_WAITING = 4;  // wait for ready to go high

    // State
    reg [3:0] state;
    //// Modulator NCOs
    reg [N_VOICES-1:0] mod_next_sample;
    wire [14*N_VOICES-1:0] mod_samples;
    //// Modulator samples
    reg [14*N_VOICES-1:0] mod_samples_ff;
    //// Sign extended and shifted modulator samples
    reg [24*N_VOICES-1:0] mod_samples_shifted;
    reg [24*N_VOICES-1:0] carrier_fcws_modulated;
    //// Carrier NCOs
    reg [N_VOICES-1:0] carrier_next_sample;
    wire [14*N_VOICES-1:0] carrier_samples;
    //// Carrier samples
    reg [14*N_VOICES-1:0] carrier_samples_ff;
    //// Summer
    /* verilator lint_off UNOPTFLAT */
    wire [13:0] partial_sums;
    /* lint_on */

    genvar gen_i;
    generate
        for (gen_i = 0; gen_i < N_VOICES; gen_i=gen_i+1) begin
            nco mod_nco (
                .clk(clk),
                .rst(rst),
                .fcw(mod_fcw),
                .next_sample(mod_next_sample[gen_i]),
                .code(mod_samples[(gen_i+1)*14-1:gen_i*14])
            );
        end
    endgenerate

    generate
        for (gen_i = 0; gen_i < N_VOICES; gen_i=gen_i+1) begin
            nco carrier_nco (
                .clk(clk),
                .rst(rst),
                .fcw(carrier_fcws_modulated[(gen_i+1)*24-1:gen_i*24]),
                .next_sample(carrier_next_sample[gen_i]),
                .code(carrier_samples[(gen_i+1)*14-1:gen_i*14])
            );
        end
    endgenerate
    genvar j;
    integer k, m;
    // Linear state machine
    assign sample_valid = state == STATE_WAITING;
    always @(posedge clk) begin
        if (rst) begin
            state <= STATE_FETCH_MOD;
        end else begin
            case (state)
                STATE_FETCH_MOD: state <= STATE_SET_FCW;
                STATE_SET_FCW: state <= STATE_FETCH_CAR;
                STATE_FETCH_CAR: state <= STATE_SUM;
                STATE_SUM: state <= STATE_WAITING;
                STATE_WAITING: state <= (sample_valid && sample_ready) ? STATE_FETCH_MOD : state;
            endcase
        end
    end

    // Fetch and save modulator samples
    always @(posedge clk) begin
        if (state == STATE_FETCH_MOD) begin
            mod_samples_ff <= mod_samples;
        end
    end

    // mod next sample enable 
    // always @(*) begin
    //     for ( i = 0 ; i<N_VOICES ; i++) begin
    //         mod_next_sample[i] = (state == STATE_FETCH_MOD) && note_en[i];
    //     end
    // end
    // assign mod_next_sample[i] = (state == STATE_FETCH_MOD) && note_en[i];

    // Sign extend and shift modulator samples to FCW size
    generate
        for (j = 0; j < N_VOICES; j =j+1 ) begin
            always @(posedge clk) begin
                if (state == STATE_SET_FCW) begin
                    mod_samples_shifted[(j+1)*24-1:j*24] <= ({{10{mod_samples_ff[(j+1)*14-1]}}, mod_samples_ff[(j+1)*14-1:j*14]}) << mod_shift;
                end
            end
        end
    endgenerate
    // 
    // always @(*) begin
    //     for ( i = 0 ; i<N_VOICES ; i++ ) begin
    //         carrier_fcws_modulated[i] = carrier_fcws[i] + mod_samples_shifted[i];
    //         end
    // end

    // assign carrier_fcws_modulated[i] = carrier_fcws[i] + mod_samples_shifted[i];

    // Fetch and save carrier samples
    always @(posedge clk) begin
        if (state == STATE_FETCH_CAR) begin
            carrier_samples_ff <= carrier_samples;
        end
    end

    genvar i;

    // carrier sample enable 
    generate
        for (i = 0; i < N_VOICES; i = i + 1) begin
            always @(*) begin
                mod_next_sample[i] = (state == STATE_FETCH_MOD) && note_en[i];
                carrier_next_sample[i] = (state == STATE_FETCH_CAR) && note_en[i];
                carrier_fcws_modulated[(i+1)*24-1:i*24] = carrier_fcws[(i+1)*24-1:i*24] + mod_samples_shifted[(i+1)*24-1:i*24];
            end
        end
    endgenerate
    // cal the sum of sample
    // always @(*) begin
    //     for ( m = 0 ; m<N_VOICES ; m++ ) begin
    //         partial_sums = (note_en[m]) ? partial_sums : carrier_samples_ff[m] + partial_sums;
    //         end
    //     sample = partial_sums;
    // end
    generate
        case (N_VOICES)
            0: assign partial_sums = 0;
            1: assign partial_sums = carrier_samples[1*14-1:0];
            2: assign partial_sums = carrier_samples[1*14-1:0] + carrier_samples[2*14-1:1*14];
            3:
            assign partial_sums = carrier_samples[1*14-1:0] + carrier_samples[2*14-1:1*14] + carrier_samples[3*14-1:2*14];
            4:
            assign partial_sums = carrier_samples[1*14-1:0] + carrier_samples[2*14-1:1*14] + carrier_samples[3*14-1:2*14] + carrier_samples[4*14-1:3*14];
            default:
            assign partial_sums = 0;
        endcase
    endgenerate

    // assign carrier_next_sample = (state == STATE_FETCH_CAR) && note_en;
    assign sample = partial_sums;
endmodule
