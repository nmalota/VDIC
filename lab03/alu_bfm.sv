`timescale 1ns/1ps
interface alu_bfm;
	import alu_pkg::*;
	

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

	bit sin;
	wire sout;
	bit clk;
	bit rst_n;
	bit [31:0] C;
	bit [31:0] A;
	bit [31:0] B;
	bit [3:0] FLAGS;
	bit ERROR;
	bit expected_err_data;
	bit expected_err_op;
	bit expected_err_crc;
	bit [2:0] CRC;
	bit [3:0] CRC_in;
	bit				   flag;
	bit [2:0] A_len;
	bit [2:0] B_len;
	wire        [2:0]  op;
	operation_t        op_set;

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

	initial begin : clk_gen
		clk = 0;
		forever begin : clk_frv
			#10;
			clk = ~clk;
		end
	end


//------------------------------------------------------------------------------
// sending tasks
//------------------------------------------------------------------------------
	task send1byte (input [7:0] data_tmp, input ctl);
		begin
			reg [10:0] data;
			data = {1'b0, ctl, data_tmp, 1'b1};
			for (int i=0; i<11; i++)
			begin
				@(negedge clk);
				sin = data[10-i];
			end
		end
	endtask
//------------------------------------------------------------------------------
	task send1data (input bit [31:0] A, input bit [31:0] B, input bit [2:0] OP, bit[2:0] A_len, bit[2:0] B_len, bit [3:0] CRC_in );
		begin
			for (int i=0; i<B_len; i++)
			begin
				send1byte(B[31-8*i -: 8], 1'b0);
			end
			for (int i=0; i<A_len; i++)
			begin
				send1byte(A[31-8*i -: 8], 1'b0);
			end
			send1byte({1'b0,OP,CRC_in}, 1'b1);
		end
	endtask
//------------------------------------------------------------------------------
// receiving tasks
//------------------------------------------------------------------------------
	task get1byte (output [7:0] data, output ctl);
		begin
			reg [10:0] dataout;
			@(negedge sout);
			for (int i=0; i<11; i++)
			begin
				@(negedge clk);
				dataout[10-i] = sout;
			end
			ctl = dataout[9];
			data = dataout[8:1];
		end
	endtask
//------------------------------------------------------------------------------
	task get1data (output bit [31:0] C,output bit [3:0] FLAGS, output bit [2:0] CRC);
		begin
			bit ctlout;
			bit [7:0] data;
			ERROR = 1'b0;
			get1byte(C[31:24],ctlout);
			if (ctlout==1'b0)
			begin
				for (int i=1; i<4; i++)
				begin
					get1byte(C[31-8*i -: 8], ctlout);
				end
				get1byte(data[7:0], ctlout);
				FLAGS = data[6:3];
				CRC = data[2:0];
			end
			else
				ERROR = 1'b1;
		end
	endtask
//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
	task reset_alu();
	`ifdef DEBUG
		$display("%0t DEBUG: reset_alu", $time);
	`endif
		rst_n = 1'b0;
		sin=1'b0;
		#100;
		@(negedge clk);
		sin=1'b1;
		rst_n = 1'b1;
	endtask
//------------------------------------------------------------------------------

endinterface : alu_bfm







