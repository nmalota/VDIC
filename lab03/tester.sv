`timescale 1ns/1ps
module tester(alu_bfm bfm);
import alu_pkg::*;
//---------------------------------
// Random data generation functions
//---------------------------------
	function operation_t get_op();
		bit [2:0] op_choice;
		op_choice = 3'($random);
		case (op_choice)
			3'b000 : return and_op;
			3'b001 : return or_op;
			3'b010 : return bad_op1;
			3'b011 : return bad_op2;
			3'b100 : return add_op;
			3'b101 : return sub_op;
			3'b110 : return bad_op3;
			3'b111 : return bad_op4;
		endcase // case (op_choice)
	endfunction : get_op

//------------------------------------------------------------------
	function bit [31:0] get_data();
		bit [1:0] zero_ones;
		zero_ones = 2'($random);
		if (zero_ones == 2'b00)
			return 32'h00000000;
		else if (zero_ones == 2'b11)
			return 32'hFFFFFFFF;
		else
			return 32'($random);
	endfunction : get_data
	
	function bit [2:0] get_len();
		bit correct;
		correct = 1'($random);
		if (correct)
			return 3'd4;
		else
			return {1'b0, 2'($random)};
	endfunction : get_len
	
	function bit [3:0] get_crc();
		bit correct;
		correct = 1'($random);
		if (correct)
			return nextCRC4_D68({bfm.B,bfm.A,1'b1,bfm.op},0);
		else
			return 4'($random);
	endfunction : get_crc

// Tester main

	initial begin : tester
		bfm.reset_alu();
		repeat (10000) begin : tester_main
			@(negedge bfm.clk);
			bfm.reset_alu();
			bfm.op_set = get_op();
			bfm.A      = get_data();
			bfm.B      = get_data();
			bfm.A_len  = get_len();
			bfm.B_len  = get_len();
		    bfm.CRC_in = get_crc();
			
			bfm.send1data(bfm.A,bfm.B,bfm.op_set,bfm.A_len, bfm.B_len, bfm.CRC_in);
			bfm.get1data(bfm.C, bfm.FLAGS, bfm.CRC);
			bfm.flag = 1'b1;
//        	if($get_coverage() == 100) break;
		end
		$finish;
	end : tester	
endmodule : tester