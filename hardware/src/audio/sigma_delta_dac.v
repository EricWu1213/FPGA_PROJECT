module sigma_delta_dac #(
    parameter CODE_WIDTH = 10
)(
    input clk,
    input rst,
    input [CODE_WIDTH-1:0] code,
    output pwm
);
    // Remove this line once you have implemented this module
    reg [10:0] register;
    wire [10:0] next_value;
    assign next_value = code + register ;
    always @(posedge clk ) begin
        if(rst) begin
            register <= 11'b0;
        end
        else begin
            register <= next_value;
        end
    end
    assign pwm = register[10] ^ next_value[10]; 
endmodule
