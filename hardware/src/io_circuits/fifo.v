module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 32,
    parameter POINTER_WIDTH = $clog2(DEPTH)
) (
    input clk, rst,
    // Write side
    input wr_en,
    input [WIDTH-1:0] din,
    output full,
    // Read side
    input rd_en,
    output [WIDTH-1:0] dout,
    output empty
);
    reg [WIDTH-1:0] FIFO [0:DEPTH-1];
    reg [POINTER_WIDTH:0] wr_ptr = 0;
    reg [POINTER_WIDTH:0] rd_ptr = 0;
    reg [POINTER_WIDTH:0] wr_cnt = 0; 
    reg [POINTER_WIDTH:0] rd_cnt = 0;
    reg [WIDTH-1:0] temp_dout;
    wire fifo_test = !full && wr_en;
    assign full = (wr_cnt - rd_cnt) == DEPTH;
    assign empty = wr_cnt == rd_cnt;
    assign dout = FIFO[rd_ptr];
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            wr_cnt <= 0;
            rd_cnt <= 0;
        end else begin
            if (!full && wr_en) begin
                // if (wr_en) begin
                    FIFO[wr_ptr] <= din;
                    wr_ptr <= (wr_ptr + 1) % DEPTH;
                    wr_cnt <= wr_cnt + 1;
                // end
            end
            if(!empty && rd_en) begin 
                // if (rd_en) begin
                    // temp_dout = FIFO[rd_ptr];
                    rd_ptr <= (rd_ptr + 1) % DEPTH;
                    rd_cnt <= rd_cnt + 1;
                // end
            end
        end
    end

    // property wr_ptr_test;
    //     @(posedge clk) disable iff (rst)
    //     (full && !rst) |-> ##1 (wr_ptr == $past(wr_ptr));
    // endproperty
    
    // property rd_ptr_test;
    //     @(posedge clk) disable iff (rst)
    //     (empty && !rst) |-> ##1 (rd_ptr == $past(rd_ptr));
    // endproperty
    // assert property (wr_ptr_test);
    // assert property (rd_ptr_test);
    // assert property (@(posedge clk) (rst) |-> (wr_ptr == 0 && rd_ptr == 0 && !full));
endmodule
