module assert_iverilog (clk,in);
 
// input & output
input clk;
input in;
 
// wire & reg;
// wire clk;
// wire in;
 
// inner wire & reg
 
/* none */
 
// always clause defined here
 
always @(posedge clk)
begin
	if(in == 1'bx) begin
		$display("assert happened in %m in=%d\n",in);
	end
	else if(in !== 1)
	begin
		$display("assert happened in %m in=%d\n",in );
		// $finish;
	end
end
 
endmodule