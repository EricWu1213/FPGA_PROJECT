module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required, one saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    // Remove this line once you have created your debouncer
    // assign debounced_signal = 0;

    reg [WRAPPING_CNT_WIDTH-1:0] wrapping_counter = 0;
    wire spg_pulse;
    
    // Wrapping counter to check sample pulse generator
    always @(posedge clk) begin
        if (wrapping_counter == SAMPLE_CNT_MAX) begin 
            wrapping_counter <= 0;
        end
        else begin
            wrapping_counter <= wrapping_counter + 1;
        end
    end
    assign spg_pulse = (wrapping_counter == SAMPLE_CNT_MAX);

    reg [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];

    genvar i;
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : saturating_counter_gen
            always @(posedge clk) begin
                if (spg_pulse) begin                            // sample pusle = 1
                    if (glitchy_signal[i]) begin                //input sign == 1
                        if (saturating_counter[i] < PULSE_CNT_MAX) begin
                            saturating_counter[i] <= saturating_counter[i] + 1'b1; 
                        end
                    end
                    else begin                                  // input signal == 0
                        saturating_counter[i] <= 0;                       
                    end
                end
                
            end
        end
    endgenerate

    generate
        for (i=0; i < WIDTH; i = i + 1) begin : debounced_signal_gen
            assign debounced_signal[i] = (saturating_counter[i] == PULSE_CNT_MAX);
        end
    endgenerate
    

    
endmodule
