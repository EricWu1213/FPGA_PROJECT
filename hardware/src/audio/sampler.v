module sampler (
    input clk,
    input rst,
    input synth_valid,
    input [9:0] scaled_synth_code,
    output synth_ready,
    output pwm_out
);

    reg [11:0] sample_cnt;
    reg [9:0] scaled_synth_code_reg;
    // clk count 150 MHz / 2500 = 60 kHz
    always @(posedge clk ) begin
        if(rst) begin
            sample_cnt <= 12'b0 ;
        end
        else if ( sample_cnt >= 2499 )begin
            sample_cnt <= 12'b0 ;
        end
        else begin
            sample_cnt <= sample_cnt + 12'b1 ;
        end
    end

    assign synth_ready = (sample_cnt == 12'b01 ) ; 

    always @(posedge clk ) begin
        if(rst) begin
            scaled_synth_code_reg <= 12'b0 ;
        end
        else if ( (scaled_synth_code != scaled_synth_code_reg) &&  synth_valid )begin
            scaled_synth_code_reg <= scaled_synth_code ;
        end
    end

    sigma_delta_dac #(
        .CODE_WIDTH(10)
    ) sigma_delta_dac_inst (
        .clk (clk),
        .rst (rst),
        .code(scaled_synth_code_reg),
        .pwm (pwm_out)
    );
endmodule
