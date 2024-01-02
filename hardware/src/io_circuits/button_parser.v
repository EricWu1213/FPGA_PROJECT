// This module instantiates the synchronizer -> debouncer -> edge detector signal chain for button inputs
module button_parser #(
    parameter WIDTH = 1,
    parameter SAMPLE_CNT_MAX = 62500,
    parameter PULSE_CNT_MAX = 200
) (
    input clk,
    input rst,
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out,
    input read_enable,
    output empty
);
    wire [WIDTH-1:0] synchronized_signals;
    wire [WIDTH-1:0] debounced_signals;

    synchronizer #(
        .WIDTH(WIDTH)
    ) button_synchronizer (
        .clk(clk),
        .async_signal(in),
        .sync_signal(synchronized_signals)
    );

    debouncer #(
        .WIDTH(WIDTH),
        .SAMPLE_CNT_MAX(SAMPLE_CNT_MAX),
        .PULSE_CNT_MAX(PULSE_CNT_MAX)
    ) button_debouncer (
        .clk(clk),
        .glitchy_signal(synchronized_signals),
        .debounced_signal(debounced_signals)
    );
    wire wr_en;
    wire [WIDTH-1:0] btn_pulse;
    assign wr_en = btn_pulse!=0;
    edge_detector #(
        .WIDTH(WIDTH)
    ) button_edge_detector (
        .clk(clk),
        .signal_in(debounced_signals),
        .edge_detect_pulse(btn_pulse)
    );

    fifo #(
        .WIDTH(WIDTH),
        .DEPTH(8),
        .POINTER_WIDTH(3)
    ) fifo_inst (
        .clk  (clk),
        .rst  (rst),
        .wr_en(wr_en),
        .din  (btn_pulse),
        // .full (full),
        .rd_en(read_enable),
        .dout (out),
        .empty(empty)
    );
endmodule
