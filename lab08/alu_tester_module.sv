/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
module alu_tester_module(alu_bfm bfm);
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
//------------------------------------------------------------------
	function bit [2:0] get_len();
		bit correct;
		correct = 1'($random);
		if (correct)
			return 3'd4;
		else
			return {1'b0, 2'($random)};
	endfunction : get_len
//------------------------------------------------------------------
	function bit [3:0] get_crc(bit [31:0] A, bit [31:0] B, operation_t op_set);
		bit correct;
		correct = 1'($random);
		if (correct)
			return nextCRC4_D68({B,A,1'b1,op_set},0);
		else
			return 4'($random);
	endfunction : get_crc

//------------------------------------------------------------------------------
// Tester main

	initial begin : tester
		ALU_in_t ALU_in;
		bfm.reset_alu();
		repeat (10000) begin : tester_main
			@(negedge bfm.clk);
			ALU_in.A = get_data();
			ALU_in.B = get_data();
			ALU_in.A_len = get_len();
			ALU_in.B_len = get_len();
			ALU_in.op_set = get_op();
			ALU_in.CRC_in = get_crc(ALU_in.A, ALU_in.B, ALU_in.op_set);
			
			bfm.send_op(ALU_in);
		end
	end
endmodule : alu_tester_module





