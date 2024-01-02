module nco (
    input clk,
    input rst,
    input [23:0] fcw,
    input next_sample,
    output [13:0] code
);

    wire [ 7:0] address;
    wire [13:0] lut_out;
    // assign lut_out = rst ? 14'b0 : lut_out ; 
    sine_lut sine_lut_inst (
        .address(address),
        .data(code)
    );
    reg [23:0] phase_accumulator ;
    always @(posedge clk) begin
        if (rst) begin
            phase_accumulator <= 24'b0;
        end
        if (next_sample) begin
            phase_accumulator <= phase_accumulator + fcw;
        end
    end
    assign address = phase_accumulator[23:16];
endmodule
