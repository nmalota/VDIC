module apple_tb(

); 
reg a=0;
reg b=0;
reg clk=0;
wire q;

apple u_apple (
	.a  (a),
	.b  (b),
	.clk(clk),
	.q  (q)
	);
	
	always clk=#5 ~clk;
	initial begin
		#10;
		a=1;
		b=1;
		#30;
		$finish();
		end
endmodule
